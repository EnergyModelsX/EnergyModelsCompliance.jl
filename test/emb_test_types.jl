# This function incorprates test types that are utilized in multiple subfiles
# These test types have no practical meaning, they are only developed for analysing that the
# access function handling is working
struct TestNode <: NetworkNode
    id::Any
end
struct TestSink <: Sink
    id::Any
end
struct TestStorage{T} <: Storage{T}
    id::Any
    lvl::Any
end
