require_relative 'raw'
require_relative '../http_error'
require_relative '../response'

def controlled_execution(file, req)
    runenv = binding
    runenv.eval file, req.path
    return runenv.method(req.req_method.downcase).call(req)
end

class ControllerRenderer < RawRenderer
    def solve_response(res)
        return res if res.class == Response
        return Response.to res.last if res.first == :redirect
        Response.ok res.last, 'Content-Type' => content_type(res.first)
    end

    def render(req)
        src = yield :file, req.path
        solve_response controlled_execution(src, req)
    end
end