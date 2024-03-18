import std.stdio;

import std.json;

import raven.document_store;

import jsonizer.tojson;

import person;

void main()
{
	DocumentStore store = new DocumentStore("http://10.0.0.14:8080","Zsyp");

	//RavenQueryResult query = store.run_query("from \"DatasetShards\" select Id",0,10);

	store.store_document(toJSON!(*new Person("krzysztof","cubich")),"Person","idk");

	//writeln(query.get_result_ids()[1]);

	//writeln(store.load_document("DatasetShards/79839-A").toPrettyString());
}
