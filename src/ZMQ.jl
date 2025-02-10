# Support for ZeroMQ, a network and interprocess communication library

module ZMQ

using Base.Libc: EAGAIN
using FileWatching: UV_READABLE, uv_pollcb, FDWatcher
import Sockets
using Sockets: connect, bind, send, recv
import Base.GC: @preserve

export
    #Types
    StateError,Context,Socket,Message,
    #functions
    set, subscribe, unsubscribe,
    #Constants
    IO_THREADS,MAX_SOCKETS,PAIR,PUB,SUB,REQ,REP,ROUTER,DEALER,PULL,PUSH,XPUB,XSUB,XREQ,XREP,UPSTREAM,DOWNSTREAM,MORE,POLLIN,POLLOUT,POLLERR,STREAMER,FORWARDER,QUEUE,SNDMORE,
    #Sockets
    connect, bind, send, recv

include("bindings.jl")
include("constants.jl")
include("optutil.jl")
include("error.jl")
include("context.jl")
include("socket.jl")
include("sockopts.jl")
include("message.jl")
include("msg_bindings.jl")
include("comm.jl")

"""
    lib_version()

Get the libzmq version number.
"""
function lib_version()
    major = Ref{Cint}()
    minor = Ref{Cint}()
    patch = Ref{Cint}()
    lib.zmq_version(major, minor, patch)
    return VersionNumber(major[], minor[], patch[])
end

const version = lib_version()

function __init__()
    if lib_version() < v"3"
        error("ZMQ version $version < 3 is not supported")
    end
    atexit() do
        close(_context)
    end
end

end
