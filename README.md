* Introduction
  
    ```.tfw``` files are used to input wave-shape data to the oscilloscopes.
    The original python code are from the web forum of Tektronix [Python Read/Write AFG TFW](https://forum.tek.com/viewtopic.php?t=140915), authored by Carl M.

    This package is just a julia version of these codes.

* Usages
  
  * ```Writetfw(Target::String, DacValues::Vector{<:Integer};   EnvelopeFlag::Bool=true)```

    Use this function to write tfw files.

    ```Target``` should be something like ```Example.tfw```.

    ```DacValues``` should be a integer vector, with minimum as 0 and maximum as 16382.

  * ```NormalVector(Values::Vector{<:Real})```
    
    This function helps you to convert a vector into the one which satisfies the requirements of ```DacValues```.

  * ```ExampleUsage(File::String="Example.tfw")```

    Write a file named as ```Example.tfw```.
  