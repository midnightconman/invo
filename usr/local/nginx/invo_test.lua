
local luaUnit = require "luaunit"
local invo = require "invo.base"

Test_invo_base = {} --class

    function Test_invo_base:test_1_parse_post_args()
        ngx.say( "Unit Testing parse_post_args Function..." )
        assertEquals( invo:parse_post_args("body"), nil )
        assertEquals( invo:parse_post_args(), nil )
    end

    function Test_invo_base:test_1_string_split()
        ngx.say( "Unit Testing string.split Function..." )
        local t = { "a", "b", "c" }
        local tt = {}
        for i in string.split("a,b,c", ",") do
            table.insert(tt, i)
        end
        assertEquals( tt, t )
    end

    function Test_invo_base:test5()
        ngx.say( "some stuff test 5" )
        assertTrue( true )
        assertFalse( nil )
    end

local lu = LuaUnit:new()
lu:setOutputType("TEXT")
ngx.say ( lu:run() )
