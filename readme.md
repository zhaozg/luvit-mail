# About Mail   

This is clone from smtp part of [luasocket](https://github.com/diegonehab/luasocket),  and update as a module as luvit.  Now, it only support send mail use smtp protocol.

To obtain the _mail_</tt> module, use luvit to run:
```lua
local mail = require("mail")
```

##SMTP

###send

To send a mail, use _send_ method
```lua
    mail.send({
        server=server,
        user=user,
        password=password,
        from = from,
        rcpt = rcpt,
        message = message
    },function(err,message)
      ...
    end)
```
The first parameter must be Lua table, support fields please check follow tables.

| fields        | types                      |
| ------------- |----------------------------|
| from          | _string_                   | 
| rcpt          | _string_ or _string-table_ | 
| source        | _LTN12 source_ or _nil_    |
| user          | _string_                   | 
| password      | _string_                   |
| server        | _string_                   | 
| port          | _number_                   |
| domain        | _string_                   |
| message       | _string_                   |


-  `user` and `password`:  User and password for authentication. The function will attempt LOGIN and PLAIN authentication methods if supported by the server (both are unsafe);
-  `server`: Server to connect to. Defaults to "localhost";
-  `port`: Port to connect to. Defaults to 25;
-  `domain`: Domain name used to greet the server; Defaults to the local machine host name;
-  `step`: [LTN12](http://lua-users.org/wiki/FiltersSourcesAndSinks) pump step function used to pass data from the source to the server. Defaults to the LTN12 <tt>pump.step</tt> function;
-  `message`:  Plain text message body;
-  `source`:  complex message body, please look at [`message`](#message), will be encode by mail.message, and convert to plain message source.

The second paramater is lua function, when mail after sent or error, it will be called. If `err` and `message` is `nil`,  then message send successfully, or get more fail information from `err` and `message`.

### message

Create an SMTP message body, possibly multipart (arbitrarily deep), use `mail.message`.

```lua
local mesg = mail.message(mesgt)	
```

Returns a simple LTN12 source that sends 

The only parameter of the function is a table describing the message. Mesgt has the following form (notice the recursive structure):
```
mesgt = {
  headers = header-table,
  body = LTN12 source or string or multipart-mesgt
}
```

####message headers
MIME headers are represented as a Lua table in the form:
```lua
headers = {
	field_1_name = _field_1_value_,  
	field_2_name = _field_2_value_,  
	field_3_name = _field_3_value_,  
	...  
	field_n_name = _field_n_value_  
}
```
Field names are case insensitive (as specified by the standard) and all functions work with lowercase field names. Field values are left unmodified.

Note: MIME headers are independent of order. Therefore, there is no problem in representing them in a Lua table.

####multipart message
```
multipart-mesgt = {
  [preamble = string,]
  [1] = mesgt,
  [2] = mesgt,
  ...
  [n] = mesgt,
  [epilogue = string,]
}
```
For a simple message, all that is needed is a set of headers and the body. The message body can be given as a string or as a simple LTN12 source. For multipart messages, the body is a table that recursively defines each part as an independent message, plus an optional preamble and epilogue.

The function returns a simple LTN12 source that produces the message contents as defined by mesgt, chunk by chunk. Hopefully, the following example will make things clear. When in doubt, refer to the appropriate RFC as listed in the introduction.

#examples
```lua
-- load the smtp support and its friends
local mail = require("mail")
local ltn12 = mail.ltn12
local mime = mail.mime

-- creates a source to send a message with two parts. The first part is 
-- plain text, the second part is a PNG image, encoded as base64.
source = mail.message{
  headers = {
     -- Remember that headers are *ignored* by smtp.send. 
     from = "Sicrano de Oliveira <sicrano@example.com>",
     to = "Fulano da Silva <fulano@example.com>",
     subject = "Here is a message with attachments"
  },
  body = {
    preamble = "If your client doesn't understand attachments, \r\n" ..
               "it will still display the preamble and the epilogue.\r\n" ..
               "Preamble will probably appear even in a MIME enabled client.",
    -- first part: no headers means plain text, us-ascii.
    -- The mime.eol low-level filter normalizes end-of-line markers.
    [1] = { 
      body = mime.eol(0, [[
        Lines in a message body should always end with CRLF. 
        The smtp module will *NOT* perform translation. However, the 
        send function *DOES* perform SMTP stuffing, whereas the message
        function does *NOT*.
      ]])
    },
    -- second part: headers describe content to be a png image, 
    -- sent under the base64 transfer content encoding.
    -- notice that nothing happens until the message is actually sent. 
    -- small chunks are loaded into memory right before transmission and 
    -- translation happens on the fly.
    [2] = { 
      headers = {
        ["content-type"] = 'image/png; name="image.png"',
        ["content-disposition"] = 'attachment; filename="image.png"',
        ["content-description"] = 'a beautiful image',
        ["content-transfer-encoding"] = "BASE64"
      },
      body = ltn12.source.chain(
        ltn12.source.file(io.open("image.png", "rb")),
        ltn12.filter.chain(
          mime.encode("base64"),
          mime.wrap()
        )
      )
    },
    epilogue = "This might also show up, but after the attachments"
  }
}

-- finally send it
r, e = smtp.send{
    from = "<sicrano@example.com>",
    rcpt = "<fulano@example.com>",
    source = source,
}
```

# [more detail](http://w3.impa.br/~diego/software/luasocket/smtp.html)


