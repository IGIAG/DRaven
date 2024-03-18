module raven.document_store;

import requests;

import std.json;

import std.conv;

import std.stdio;

class DocumentStore
{
    private string database_name = "";

    private string ravendb_url = "";

    public this(string ravendb_url, string database_name)
    {
        this.ravendb_url = ravendb_url;
        this.database_name = database_name;
    }

    public RavenQueryResult run_query(string rql, int start, int page_size)
    {
        Request re = *new Request();

        JSONValue request_body = *new JSONValue();

        request_body["PageSize"] = page_size;
        request_body["Query"] = rql;
        request_body["Start"] = start;

        re.addHeaders(["Content-Type": "text/json"]);

        string re_uri = ravendb_url ~ "/databases/" ~ database_name ~ "/queries";

        string re_body = request_body.toString();


        Response rs = re.post(re_uri, re_body, "text/json");

        if (rs.code != 200)
        {
            throw new Exception("Query \"" ~ rql ~ "\" failed!");
        }

        JSONValue rs_json = parseJSON(to!string(rs.responseBody()));

        return *(new RavenQueryResult(to!int(rs_json["TotalResults"].integer()),
                to!int(rs_json["SkippedResults"].integer()), to!int(
                rs_json["DurationInMs"].integer()), rs_json["Results"].array()));
    }

    public JSONValue load_document(string id)
    {
        Request re = *new Request();

        Response rs = re.get(ravendb_url ~ "/databases/" ~ database_name ~ "/docs", [
                "id": id
            ]);

        if (rs.code != 200)
        {
            throw new Exception("Document " ~ id ~ " not found!");
        }
        return parseJSON(to!string(rs.responseBody()));
    }

    public RavenResultStatus store_document(JSONValue document,string collection,string id){
        document["@metadata"] = *new JSONValue();
        document["@metadata"]["@collection"] = collection;

        Request re = *new Request();

        re.addHeaders(["Content-Type": "text/json"]);

        string re_uri = ravendb_url ~ "/databases/" ~ database_name ~ "/docs";

        string re_body = document.toString();

        Response rs = re.put(re_uri ~ "?id=" ~ id, re_body, "text/json");

        switch(rs.code){
            case 200:
                return RavenResultStatus.CREATED;
            case 201:
                return RavenResultStatus.UPDATED;
            default:
                writeln(rs.responseBody());
                return RavenResultStatus.ERROR;
        }
    }
}
public enum RavenResultStatus {
    CREATED,
    UPDATED,
    ERROR
}


struct RavenQueryResult
{
    public int total_results = 0;
    public int skipped_results = 0;
    public int duration_ms = 0;

    JSONValue[] results = [];

    string[] get_result_ids()
    {
        string[] result_ids = new string[results.length];
        foreach (i,JSONValue document_json; results)
        {
            try
            {
               result_ids[i] = document_json["@metadata"]["@id"].str();
            }
            catch(Exception e){
                throw new Exception("Failed to get document Ids from query. Are you getting back docs with metadata?");
            }
        }
        return result_ids;
    }
}