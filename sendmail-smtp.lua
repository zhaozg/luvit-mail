local mail = require('mail')
local function sendmail(server, user,passwd)
    local from = "<shybt@163.com>" -- ������

    -- �����б�
    local rcpt = {
        "<zhaozg@aliyun.com>",
        "<shybt@163.com>"
    }

    local mesgt = {
        headers = {
            to = rcpt[1], -- �ռ���
            cc = rcpt[2], -- ����
            subject = "This is Mail Title"
        },
        body = "This is  Mail Content."
    }

    r, e = mail.send({
        server=server,
        user=user,
        password=passwd,
        from = from,
        rcpt = rcpt,
        --source = smtp.message(mesgt)
        message = mesgt
    },function(a,b)
        if (a or b) then
            print('Send fail:', a,b)
        else
            print('Sent successfully')
        end
    end)
end

print("Input mail server:")
local server = io.read()
print("Input mail user:")
local user = io.read()
print("Input password of ("..user.."):")
local passwd = io.read()
sendmail(server, user, passwd)
