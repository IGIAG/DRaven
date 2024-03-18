module person;

import jsonizer.jsonize;

import jsonizer.tojson;

import jsonizer;

import std.json;

struct Person {
    mixin JsonizeMe;

    public @jsonize("name") string name;

    public @jsonize("surname") string surname;
}