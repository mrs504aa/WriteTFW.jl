function VectorSplit(TargetVector::Vector{<:Real}, N::Int64)
    L1 = length(TargetVector)
    L2 = trunc(Int64, L1 / N)
    X = L1 - N * L2

    Result = Vector{Vector}(undef, N)
    CutStart = 1
    for i in 1:N
        Result[i] = TargetVector[CutStart:CutStart-1+L2+((i-1)<X)]
        CutStart += L2 + (i < X)
    end

    return Result
end

function NormalVector(Values::Vector{<:Real})
    Max = 16382
    Min = 0
    S = (Values .- minimum(Values)) ./ (maximum(Values) - minimum(Values))
    S = (S .+ Min) .* (Max - Min)
    return trunc.(UInt16, S)
end

function EnvelopeVector(DacValues::Vector{<:Integer})
    N = convert(Vector{UInt8}, DacValues .>> 6)
    Upper = nothing
    Lower = nothing
    if length(DacValues) <= 206
        Upper = N
        Lower = N
    else
        Segments = VectorSplit(N, 206)
        Upper = zeros(UInt8, 206)
        Lower = zeros(UInt8, 206)
        for (Index, S) in enumerate(Segments)
            Upper[Index] = maximum(S)
            Lower[Index] = minimum(S)
        end
    end
    return reshape(vcat(Lower', Upper'), :)
end

function PackHeader(Samples::Int64, EnvelopeFlag::Int64)
    Header = Array{UInt8,1}(undef, 512)
    Header .= 0

    Index = 1
    S = b"TEKAFG3000"
    Header[Index:(Index+length(S)-1)] .= S
    Index += length(S) + 6

    S = reinterpret(UInt8, [hton(20050114)])
    S = S[5:8]
    Header[Index:(Index+length(S)-1)] .= S
    Index += length(S)

    S = reinterpret(UInt8, [hton(Samples)])
    S = S[5:8]
    Header[Index:(Index+length(S)-1)] .= S
    Index += length(S)

    S = reinterpret(UInt8, [hton(EnvelopeFlag)])
    S = S[5:8]
    Header[Index:(Index+length(S)-1)] .= S

    return Header
end

function Writetfw(Target::String, DacValues::Vector{<:Integer}; EnvelopeFlag::Bool=true)
    D = convert(Vector{UInt16}, DacValues .& 0x3fff)
    Samples = length(D)

    Header = PackHeader(Samples, 1)
    if EnvelopeFlag
        Envelope = EnvelopeVector(D)
        Header[29:29+length(Envelope)-1] = Envelope
    end

    File = open(Target, "w")
    write(File, Header)
    write(File, hton.(D))
    close(File)
    return 0
end

function ExampleUsage(;FileName::String="Example.tfw")
    Samples = 1200
    Cycles = 32
    T = range(0, Samples-1)
    Y = sin.(T .* (pi / Samples)) .* cos.(T .* (2 * pi / Samples * Cycles))
    N = NormalVector(Y)
    Writetfw(FileName, N, EnvelopeFlag=true)
    return 0
end

export Writetfw, ExampleUsage, NormalVector