
string json_type_name(float type) {
    return switch(type) {
        case JSON_TYPE_NULL: "null",
        case JSON_TYPE_STRING: "string",
        case JSON_TYPE_NUMBER: "number",
        case JSON_TYPE_BOOL: "bool",
        case JSON_TYPE_OBJECT: "object",
        case JSON_TYPE_ARRAY: "array",
        default: "unknown"
    };
}

void json_parse_value(string token, float isquoted, float ispunctuation) {
    var c = str2chr(token, 0);

    json_value_string = token;
    json_value_float = 0;
    json_value_type = JSON_TYPE_NULL;

    if(ispunctuation) {
        if(c == '{')
            json_value_type = JSON_TYPE_OBJECT;
        else if(c == '[')
            json_value_type = JSON_TYPE_ARRAY;
    } else if(!isquoted) {
        if(token == "true") {
            json_value_type = JSON_TYPE_BOOL;
            json_value_float = 1;
        } else if(token == "false") {
            json_value_type = JSON_TYPE_BOOL;
            json_value_float = 0;
        } else if(token != "null") {
            json_value_type = JSON_TYPE_NUMBER;
            json_value_float = stof(token);
        }
    } else {
        json_value_type = JSON_TYPE_STRING;
    }
}

void json_parser_recurse(float type, float offs) {
    if(offs == json_parser_offset) {
        if(type == JSON_TYPE_OBJECT)
            json_parse_object(NULL);
        else if(type == JSON_TYPE_ARRAY)
            json_parse_array(NULL);
    }
}

void json_parse_object(json_iter_t iter) {
    var data = json_parser_data;
    var key = "";
    var val = "";
    var depth = 0;

    for(; json_parser_offset < json_parser_numtokens; ++json_parser_offset) {
        var token = argv(json_parser_offset);
        var c = str2chr(token, 0);
        var isquoted = (c != str2chr(data, argv_start_index(json_parser_offset)));
        var ispunctuation = (!isquoted && chr_in_str(c, "{}:[],"));

        if(key == "") {
            if(ispunctuation) {
                if(c == '{')
                    ++depth;
                else if(c == '}') {
                    --depth;
                    if(depth <= 0)
                        return;
                }

                continue;
            }

            key = token;
            continue;
        } else if(c == ':' || c == ',')
            continue;

        json_parse_value(token, isquoted, ispunctuation);
        var offs = json_parser_offset;
        var type = json_value_type;

        if(iter && iter(key, -1))
            return;

        json_parser_recurse(type, offs);
        key = "";
    }
}

void json_parse_array(json_iter_t iter) {
    var data = json_parser_data;
    var idx = 0;
    var depth = 0;

    for(; json_parser_offset < json_parser_numtokens; ++json_parser_offset) {
        var token = argv(json_parser_offset);
        var c = str2chr(token, 0);
        var isquoted = (c != str2chr(data, argv_start_index(json_parser_offset)));
        var ispunctuation = (!isquoted && chr_in_str(c, "{}:[],"));

        if(ispunctuation) {
            if(c == '[') {
                if(!depth) {
                    ++depth;
                    continue;
                }
            } else if(c == ']') {
                --depth;
                if(depth <= 0)
                    return;
            } else if(c != '{')
                continue;
        }

        json_parse_value(token, isquoted, ispunctuation);
        var offs = json_parser_offset;
        var type = json_value_type;

        if(iter && iter(NULL, idx))
            return;

        json_parser_recurse(type, offs);
        ++idx;
    }
}

void json_parser_init(string data) {
    json_parser_offset = 0;
    json_parser_data = data;
    json_parser_numtokens = tokenize(data);
}
