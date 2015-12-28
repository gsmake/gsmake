local module = {}

function module.ctor ()
    return {
        Text = ""
    }
end

function module:write (txt)
    self.Text = self.Text .. txt
end

return module
