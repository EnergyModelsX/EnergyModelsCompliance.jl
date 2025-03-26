# This function incorprates test types that are utilized in multiple subfiles
# These test types have no practical meaning, they are only developed for analysing that the
# access function handling is working
struct TestArea <: Area
    id::Any
end
struct TestMode <: TransmissionMode
    id::Any
end
struct TestPipe <: PipeMode
    id::Any
end
