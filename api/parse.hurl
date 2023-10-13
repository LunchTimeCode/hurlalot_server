# without body
POST {{target}}/api/parse

HTTP 400

# with valid body
POST {{target}}/api/parse
Content-Type: application/json
file,valid_hurl.json;

HTTP 200
[Asserts]
jsonpath "$.result" contains "okay"
jsonpath "$.error"  == null


# with valid body
POST {{target}}/api/parse
Content-Type: application/json
{
 "content": "not really a hurl file"
}

HTTP 200
[Asserts]
jsonpath "$.error.pos.line" == 1
jsonpath "$.result"  == null