folder = "Z:/hdb_data"
path = "marketdata/tick_20251113"
flags = 0
len = 30
db_id = hdb_open_db(folder)
redirect_stdout(devnull) do
    global fileid, type_num, ci_type_r, data_types = hdb_open_file(db_id, path, 0, len)
    data_types = data_types[1:type_num]
    push!(data_types, ci_type_r.x)
    type_num = type_num + 1
end
file = "./marketdata.jl"
vname = "marketdata"
len = type_num
generate_cstruct(data_types, type_num, file, vname)
hdb_close_file(fileid)

path = "bar/min_bar_20251113"
flags = 0
len = 30
redirect_stdout(devnull) do
    global fileid, type_num, ci_type_r, data_types = hdb_open_file(db_id, path, 0, len)
    data_types = data_types[1:type_num]
    len = type_num
end
file = "./bar.jl"
vname = "bar"
len = type_num
generate_cstruct(data_types, type_num, file, vname)
hdb_close_file(fileid)


path = "hkdata/hk_tick_20251117"
flags = 0
len = 30
redirect_stdout(devnull) do
    global fileid, type_num, ci_type_r, data_types = hdb_open_file(db_id, path, 0, len)
    data_types = data_types[1:type_num]
    push!(data_types, ci_type_r.x)
    type_num = type_num + 1
end
file = "./hkdata.jl"
vname = "hkdata"
len = type_num
generate_cstruct(data_types, type_num, file, vname)
hdb_close_file(fileid)


path = "baseinfo/SecurityInfo_20251117"
flags = 0
len = 20
redirect_stdout(devnull) do
    global fileid, type_num, ci_type_r, data_types = hdb_open_file(db_id, path, 0, len)
    data_types = data_types[1:type_num]
    push!(data_types, ci_type_r.x)
    type_num = type_num + 1
end
file = "./baseinfo.jl"
vname = "baseinfo"
len = type_num
generate_cstruct(data_types, type_num, file, vname)
hdb_close_file(fileid)

path = "fundmentals/qxdata_2022"
flags = 0
len = 30
redirect_stdout(devnull) do
    global fileid, type_num, ci_type_r, data_types = hdb_open_file(db_id, path, 0, len)
    data_types = data_types[1:type_num]
    push!(data_types, ci_type_r.x)
    type_num = type_num + 1
end
file = "./fundmentals.jl"
vname = "fundmentals"
len = type_num
generate_cstruct(data_types, type_num, file, vname)
hdb_close_file(fileid)

path = "staticinfo/ETF_20251117"
flags = 0
len = 30
redirect_stdout(devnull) do
    global fileid, type_num, ci_type_r, data_types = hdb_open_file(db_id, path, 0, len)
    data_types = data_types[1:type_num]
    push!(data_types, ci_type_r.x)
    type_num = type_num + 1
end
file = "./staticinfo.jl"
vname = "staticinfo"
len = type_num
generate_cstruct(data_types, type_num, file, vname)
hdb_close_file(fileid)

path = "zzzsdata/zzzs_tick_20251117"
flags = 0
len = 30
redirect_stdout(devnull) do
    global fileid, type_num, ci_type_r, data_types = hdb_open_file(db_id, path, 0, len)
    data_types = data_types[1:type_num]
    push!(data_types, ci_type_r.x)
    type_num = type_num + 1
end
file = "./zzzsdata.jl"
vname = "zzzsdata"
len = type_num
generate_cstruct(data_types, type_num, file, vname)
hdb_close_file(fileid)
