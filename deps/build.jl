using Pkg.Artifacts

function main()
    println("Building HDB package...")
    
    # 确保 artifact 可用
    artifact_path = artifact"hdb_library"
    println("HDB libraries available at: $artifact_path")
    
    # 验证库文件
    if Sys.iswindows()
        lib_path = joinpath(artifact_path, "hdb.dll")
        clientlib_path = joinpath(artifact_path, "hdbclient.dll")
    elseif Sys.islinux()
        lib_path = joinpath(artifact_path, "libhdb.so")
        clientlib_path = joinpath(artifact_path, "libhdbclient.so")
    end
    
    if isfile(lib_path) && isfile(clientlib_path)
        println("✓ HDB libraries verified successfully")
    else
        error("HDB libraries not found in artifact")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end