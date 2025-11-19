module HDB
using Dates
using StringEncodings
using CBinding
using Pkg.Artifacts
c``
c"#include <stdint.h>"
const MODULE_ROOT = @__DIR__

# 使用 Artifacts 动态加载库文件
function __init__()
    # 确保 artifact 可用
    lib_dir = artifact"hdb_library"
    
    # 根据平台设置库路径
    global lib, clientlib
    if Sys.iswindows()
        lib = joinpath(lib_dir, "hdb.dll")
        clientlib = joinpath(lib_dir, "hdbclient.dll")
    elseif Sys.islinux()
        lib = joinpath(lib_dir, "libhdb.so")
        clientlib = joinpath(lib_dir, "libhdbclient.so")
    end
    
    # 验证库文件是否存在
    if !isfile(lib) || !isfile(clientlib)
        @error "HDB library files not found. Please make sure the package is installed correctly."
    end
end

@enum HRetCode HRetCode_OK = 0 HRetCode_NotFound = -1 HRetCode_Corruption = -2 HRetCode_NotSupported = -3 HRetCode_InvalidArgument = -4 HRetCode_IOError = -5 HRetCode_Incomplete = -6 HRetCode_Full = -8 HRetCode_NotEnoughMemory = -9 HRetCode_EOF = -10 HRetCode_InvalidTime = -11 HRetCode_NetTimeout = -12 HRetCode_ConnError = -13 HRetCode_AuthError = -14 HRetCode_NetIOError = -15 HRetCode_ExceedLimit = -16
@enum HFileAccFlag HFileAcc_ReadOnly = 0 HFileAcc_ReadWrite HFileAcc_GenerateIndexFile
@enum HFieldType HFieldType_Char = 0 HFieldType_Short HFieldType_UShort HFieldType_Int HFieldType_UInt HFieldType_Long HFieldType_ULong HFieldType_Float HFieldType_Double HFieldType_CharArray HFieldType_ZeroTermCharArray HFieldType_SpaceTermCharArray HFieldType_IntArray HFieldType_ZeroTermIntArray HFieldType_UIntArray HFieldType_ZeroTermUIntArray HFieldType_LongArray HFieldType_ZeroTermLongArray HFieldType_ULongArray HFieldType_ZeroTermULongArray
@enum HFieldEncodeOp HFieldEncodeOp_Raw = 0 HFieldEncodeOp_ValueCompress HFieldEncodeOp_ValueIncCompress
@enum HFieldFlag HFieldFlag_Optional = 1
@enum HClientCreateFileOption HClientCF_FailOnExist = 0 HClientCF_ClearCurrData HClientCF_AppendData

for file in ["bar.jl", "baseinfo.jl", "fundmentals.jl", "hkdata.jl", "marketdata.jl", "staticinfo.jl"]
    file_path = joinpath(MODULE_ROOT, "struct", file)
    if isfile(file_path)
        include(file_path)
        println("HDB $file included successfully.")
    else
        @warn "HDB struct file $file not found at $file_path"
    end
end

const type_tuple = (UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64, UInt8, UInt8,
 UInt8, Int32, Int32, UInt32, UInt32, Int64, Int64, UInt64, UInt64)

const ctype_tuple = ("uint8_t", "int16_t", "uint16_t", "int32_t", "uint32_t", "int64_t", "uint64_t", "float", "double", "uint8_t", "uint8_t",
 "uint8_t", "int32_t", "int32_t", "uint32_t", "uint32_t", "int64_t", "int64_t", "uint64_t", "uint64_t")

const HDB_MAX_FILE_TYPE_NUM = 64
const HDB_MAX_DATA_FIELD_NUM = 512
const HDB_MAX_DATA_OPT_FIELD_NUM = 63
const HDB_MAX_SYMBOL_SIZE = 24
const HDB_MAX_TYPENANE_SIZE = 32
const HDB_MAX_FIELDNANE_SIZE = 32
const HDB_MAX_ITEMDATA_SIZE = 64 * 1024
const HDB_MAX_CLIENT_FILE_READ_SIZE = 250 * 1024
 
struct HDataField
  field_name::NTuple{HDB_MAX_FIELDNANE_SIZE, UInt8}
  field_type::Cint
  field_op::Cint
  field_size::Cint
  field_flags::Cint
end
export HDataField

struct HDataType
  type::NTuple{HDB_MAX_TYPENANE_SIZE, UInt8}
  field_count::Cint
  fields::NTuple{HDB_MAX_DATA_FIELD_NUM, HDataField}
  data_size::Cint
end
export HDataType

struct HDataItem
  symbol::NTuple{HDB_MAX_SYMBOL_SIZE, UInt8}
  index::Cint
  trading_day::Cint
  local_time::Int64
  time_point_seq_no::Cint
  type_id::Cint           
  data::Ptr{UInt8}
end
export HDataItem

struct HCodeInfo
  symbol::NTuple{HDB_MAX_SYMBOL_SIZE,UInt8}
  index::Cint
  total_items_num::Cint
  type_items_nums::NTuple{HDB_MAX_FILE_TYPE_NUM,Cint}
  data::Ptr{UInt8}
end
export HCodeInfo

"""
    function hdb_open_db(folder::String)::UInt64
 * 打开HDB数据库。
 *
 * @param folder        HDB数据库根目录
 *                      支持配置多个文件夹，不同文件夹之间用竖线(|)分隔
 *                      注意，创建文件时，新文件始终位于第一个文件夹下
 *
 * @return              成功返回数据库句柄，失败返回0
"""
function hdb_open_db(folder::String)::UInt64
    db = ccall((:hdb_open_db,lib), UInt64, (Cstring,), folder)
end
export hdb_open_db

"""
    hdb_create_file(db_id::UInt64, path::String, ci_type::HDataType, data_types::Vector{HDataType},
                        packet_size::Integer = 128*1024)::UInt64
 * 创建给定路径的HDB文件。
 *
 * @param db_id         数据库句柄
 * @param path          文件路径，即相对于根目录的文件相对路径
 * @param ci_type       代码信息数据类型定义，若无可设置为空指针
 * @param data_types    数据类型定义数组。输入的HDataType中的data_size字段
 *                      可不填，接口库中将根据每个字段的长度计算总的数据
 *                      类型长度。
 * @param packet_size   数据文件中数据库大小，默认为128K。若数据文件中一只代码
 *                      的一种数据类型所有数据记录总大小远小于128K，我们可以将
 *                      该参数调小来减小磁盘/内存占用。
 *
 * @return              成功返回HDB文件句柄，失败返回0
"""
function hdb_create_file(db_id::UInt64, path::String, ci_type::HDataType, data_types::Vector{HDataType},
                        packet_size::Integer = 128*1024)::UInt64
    ci_type_r = Ref{HDataType}(ci_type)
    type_num = length(data_types)
    errcode = ccall((:hdb_create_file, lib), UInt64, (UInt64, Ptr{UInt8}, Ptr{HDataType}, Ptr{HDataType}, Cint, Cint), db_id, path, ci_type_r, data_types, type_num, packet_size)
end
export hdb_create_file

"""
    hdb_close_db(db_id::UInt64)::Int32
 * 关闭HDB文件。
 *
 * @param file_id       HDB文件句柄
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_close_db(db_id::UInt64)::Int32
    errcode = ccall((:hdb_close_db,lib), Int32, (UInt64,), db_id)
end
export hdb_close_db

"""
    hdb_open_file(db_id::UInt64, path::String, flags::Integer, len::Integer=20)::Tuple{
                                UInt64,Cint,Base.RefValue{HDataType},Vector{HDataType}}
 * 打开给定路径的HDB文件。
 *
 * @param db_id         数据库句柄
 * @param path          文件路径，即相对于根目录的文件相对路径
 * @param flags         0：只读，1：读写， 2：读写方式打开数据文件并生成索引文件
 * @param len           数据类型定义数量。
 *                      输入时为输入的data_types数组长度。
 *                      若输入时该值比需要返回的数量小时，接口返回HRetCode_NotEnoughMemory
 *
 * @return fileid       成功返回HDB文件句柄，失败返回0
 * @return type_num     数据类型数量
 * @return ci_type      代码信息数据类型定义
 * @return data_types   数据类型定义数组
"""
function hdb_open_file(db_id::UInt64, path::String, flags::Integer, len::Integer=20)::Tuple{UInt64,Cint,Base.RefValue{HDataType},Vector{HDataType}}
    ci_type_r = Ref{HDataType}()
    data_types = Vector{HDataType}(undef,len)
    type_num_r = Ref{Cint}(len)
    fileid = ccall((:hdb_open_file, lib), UInt64, (UInt64, Ptr{UInt8}, Cint, Ptr{HDataType}, Ptr{HDataType}, Ptr{Cint}), db_id, path, flags, ci_type_r, data_types, type_num_r)
    type_num = type_num_r[]
    return fileid, type_num, ci_type_r, data_types
end
export hdb_open_file


function convert_chararray_to_string(field_name::Union{Tuple{Vararg{Integer}},AbstractVector{Integer}}, code::String="")
    index = findfirst(isequal(0), field_name)
    if isnothing(index)
        key = collect(UInt8,field_name)
    elseif index > 1
        key = collect(UInt8,field_name[1:index-1])
    else
        return ""
    end
    if 0 == length(code) 
        try
            decode(key,"gbk")
        catch e
            decode(key,"utf-8")
        end
    else
        decode(key, code)
    end
end
export convert_chararray_to_string

"""
    generate_cstruct(data_types::Vector{HDataType}, len::Integer)::Tuple{Vararg{DataType}}
 * 根据数据类型定义数组生成各种数据类型
 *
 * @param data_types         数据类型定义数组
 *
 * @return date_types_tuple  返回类型变量组成的元组
    
"""
function generate_cstruct(data_types::Vector{HDataType}, len::Integer)::Tuple{Vararg{DataType}}
    md_type_vector = Vector{DataType}(undef,len)
    structdefine = "begin\nc\";\n#pragma pack(push, 1)\n"
    type_names = String[]
    for j = 1:len
        md_type = data_types[j]
        fields = md_type.fields
        field_count = md_type.field_count
        type_name = unsafe_string(pointer([md_type.type...]))
        structdefine = string(structdefine,"typedef struct t_",type_name,"{\n")
        for i = 1:field_count
            field = fields[i]
            field_name = unsafe_string(pointer([field.field_name...]))
            field_type = type_tuple[field.field_type+1]
            cfield_type = ctype_tuple[field.field_type+1]
            lenfield = div(field.field_size,sizeof(field_type))
            if lenfield > 1
                structdefine = string(structdefine,cfield_type," ",field_name,"[",lenfield,"];\n")
            else
                structdefine = string(structdefine,cfield_type," ",field_name,";\n")
            end
        end
        push!(type_names, type_name)
        structdefine = string(structdefine, "}",type_name,";\n")
    end
    structdefine = string(structdefine, "#pragma pack(pop)\"\nend")
    #"生成定义结构体的表达式
    ex1 = Meta.parse(structdefine)
    eval(ex1)
    for k = 1:len
        type_name = type_names[k]
        struct_rename = string(type_name," = c\"struct t_",type_name,"\"")
        println(struct_rename)
        ex1 = Meta.parse(struct_rename)
        md_type_vector[k] = eval(ex1)
    end
    return tuple(md_type_vector...)
end

"""
    generate_cstruct(data_type::HDataType)::Tuple{Vararg{DataType}}
 * 根据数据类型定义数组生成各种数据类型
 *
 * @param data_type         数据类型定义
 *
 * @return date_types_tuple  返回类型变量组成的元组
    
"""
function generate_cstruct(data_type::HDataType)::Tuple{Vararg{DataType}}
    structdefine = "begin\nc\";\n#pragma pack(push, 1)\n"
    fields = data_type.fields
    field_count = data_type.field_count
    type_name = unsafe_string(pointer([data_type.type...]))
    structdefine = string(structdefine,"typedef struct t_",type_name,"{\n")
    for i = 1:field_count
        field = fields[i]
        field_name = unsafe_string(pointer([field.field_name...]))
        field_type = type_tuple[field.field_type+1]
        cfield_type = ctype_tuple[field.field_type+1]
        lenfield = div(field.field_size,sizeof(field_type))
        if lenfield > 1
            structdefine = string(structdefine,cfield_type," ",field_name,"[",lenfield,"];\n")
        else
            structdefine = string(structdefine,cfield_type," ",field_name,";\n")
        end
    end
    structdefine = string(structdefine, "}",type_name,";\n")
    structdefine = string(structdefine, "#pragma pack(pop)\"\n",type_name," = c\"struct t_",type_name,"\"\nend")
    #"生成定义结构体的表达式
    ex1 = Meta.parse(structdefine)
    eval(ex1)
end


"""
    generate_cstruct(md_types::Vector{HDataType}, len::Integer, file::String, vname::String)::Cvoid
 * 根据数据类型定义数组生成各种数据类型的定义文件
 *
 * @param data_types         数据类型定义数组
 * @param len                数据类型定义数组的有效长度
 * @param file               生成的数据类型定义数组的文件名
 * @param vname              定义的数据类型变量元组的名字
    
"""
function generate_cstruct(data_types::Vector{HDataType}, len::Integer, file::String, vname::String)::Cvoid
    structdefine = "c\";\n#pragma pack(push, 1)\n"
    type_names = String[]
    for j = 1:len
        md_type = data_types[j]
        fields = md_type.fields
        field_count = md_type.field_count
        type_name = unsafe_string(pointer([md_type.type...]))
        structdefine = string(structdefine,"typedef struct t_",type_name,"{\n")
        for i = 1:field_count
            field = fields[i]
            field_name = unsafe_string(pointer([field.field_name...]))
            field_type = type_tuple[field.field_type+1]
            cfield_type = ctype_tuple[field.field_type+1]
            lenfield = div(field.field_size,sizeof(field_type))
            if lenfield > 1
                structdefine = string(structdefine,"   ",cfield_type," ",field_name,"[",lenfield,"];\n")
            else
                structdefine = string(structdefine,"   ",cfield_type," ",field_name,";\n")
            end
        end
        push!(type_names, type_name)
        structdefine = string(structdefine, "}",type_name,";\n\n")
    end
    structdefine = string(structdefine, "#pragma pack(pop)\"\n")
    #"将所定义的结构体类型都放在一个叫做vname的元组里面
    vname = string(vname," = (")
    for k = 1:len
        type_name = type_names[k]
        structdefine = string(structdefine, type_name," = c\"struct t_",type_name,"\"\n")
        vname = string(vname, type_name, ", ")
    end
    vname = string(vname, ")\n")
    structdefine = string(structdefine, vname)
    open(file,"w") do io
        write(io, structdefine)
    end
    nothing    
end
export generate_cstruct

"""
    parse_data(itemdata::HDataItem, structs_tuple::Tuple)
 * 根据数据类型元组中的类型来解析数据
 *
 * @param itemdata           数据记录
 * @param structs_tuple      数据类型元组，其中的数据类型与itemdata中的type_id一一对应
 * 
 * @return res               返回对应的数据
"""
function parse_data(itemdata::HDataItem, structs_tuple::Tuple)
    type_id = itemdata.type_id+1
    struct_type = struct_tuple[type_id]
    itemdata = convert(Cptr{struct_type}, itemdata.data)
    res = unsafe_load(itemdata)
    return res
end

"""
    parse_data(itemdata::HDataItem, struct_type::DataType)
 * 根据数据类型来解析数据HDataItem中的数据
 *
 * @param itemdata           数据记录
 * @param structs_tuple      数据类型元组，其中的数据类型与itemdata中的type_id一一对应
 * 
 * @return res               返回对应的数据
"""
function parse_data(itemdata::Union{HDataItem,HCodeInfo}, struct_type::DataType)
    itemdata = convert(Cptr{struct_type}, itemdata.data)
    res = unsafe_load(itemdata)
    return res
end

"""
    parse_data(itemdata::Ptr{UInt8}, struct_type::DataType)
 * 根据数据类型来解析数据指针
 *
 * @param itemdata           数据记录的指针
 * @param struct_type        数据类型
 * 
 * @return res               返回对应的数据
"""
function parse_data(itemdata::Ptr{UInt8}, struct_type::DataType)
    itemdata = convert(Cptr{struct_type}, itemdata)
    res = unsafe_load(itemdata)
    return res
end
export parse_data

"""
    parse_datetime(item::HDataItem)
 * 根据数据记录来解析数据的localtime
 *
 * @param item               数据记录
 * 
 * @return datet             返回对应的日期，如:20250318
 *         timet             返回对应的时间，如:163201500
"""
function parse_datetime(item::HDataItem)
    datet = parse(Int32,Libc.strftime("%Y%m%d",item.local_time/1000))
    timet = parse(Int32,Libc.strftime("%H%M%S",item.local_time/1000))*1000 + rem(item.local_time,1000)
    return datet, timet
end
export parse_datetime

"""
    parse_symbols(items::Vector{HCodeInfo})
 * 根据CodeInfo记录来解析数据的标的代码
 *
 * @param items              CodeInfo记录列表，类型为：Vector{HCodeInfo}
 * 
 * @return symbols           返回对应的标的代码，类型为：Vector{String}
"""
function parse_symbols(items::Vector{HCodeInfo})
    ptr = pointer(items)
    len = length(items)
    ptrvec = convert.(Ptr{UInt8},[ptr+(i-1)*sizeof(HCodeInfo) for i = 1:len])
    symbols = unsafe_string.(ptrvec)
end
export parse_symbols

"""
    parse_symbols(items::Vector{HDataItem})
 * 根据数据记录来解析数据的标的代码
 *
 * @param items              数据记录列表，类型为：Vector{HDataItem}
 * 
 * @return symbols           返回对应的标的代码，类型为：Vector{String}
"""
function parse_symbols(items::Vector{HDataItem})
    ptr = pointer(items)
    len = length(items)
    ptrvec = convert.(Ptr{UInt8},[ptr+(i-1)*sizeof(HDataItem) for i = 1:len])
    symbols = unsafe_string.(ptrvec)
end
export parse_symbols

"""
    hdb_close_file(file_id::UInt64)::Cint
 * 关闭HDB文件。
 *
 * @param file_id       HDB文件句柄
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_close_file(file_id::UInt64)::Cint
    errcode = ccall((:hdb_close_file,lib), Int32, (UInt64,), file_id)
end
export hdb_close_file

"""
    hdb_write_codes(file_id::UInt64, codes::Vector{HCodeInfo})::Cint
 * 向HDB文件中写入代码信息。同一只代码支持多次提交，最近一次提交将
 * 覆盖之前提交的代码信息。
 * 写入时仅需填充symbol及data字段，若不存在自定义代码基本信息，data字段也
 * 可填为空指针。
 *
 * @param file_id       HDB文件句柄
 * @param codes         代码信息数组。写入时HCodeInfo中的
 *                      index,total_items_num,type_items_nums这几个字段可
 *                      不填写，系统内部会给这几个字段赋值。
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_write_codes(file_id::UInt64, codes::Vector{HCodeInfo})::Cint
    len = length(codes)
    errcode = ccall((:hdb_write_codes,lib), Int32, (UInt64, Ptr{HCodeInfo}, Cint), file_id, codes, len)
end
export hdb_write_codes

"""
    hdb_write_codelist(file_id::UInt64, cl_name::String, symbol_list::Union{Vector{String},
                       Tuple{Vararg{String}}})::Cint
 * 向HDB文件中写入一个代码列表。一个代码列表即一个给定名称的代码集合，
 * 集合中的代码必须为文件中已存在的代码(通过write_codes接口写入过代码信息，
 * 或者通过write_items接口写入过数据记录)。
 *
 * @param file_id       文件句柄
 * @param cl_name       代码列表名称
 * @param symbol        Tuple或者Vector组成的代码列表
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_write_codelist(file_id::UInt64, cl_name::String, symbol_list::Union{Vector{String},Tuple{Vararg{String}}})::Cint
    symbols = join(symbol_list, ",")
    errcode = ccall((:hdb_write_codelist,lib), Int32, (UInt64, Ptr{UInt8}, Ptr{UInt8}), file_id, cl_name, symbols)
end

"""
    hdb_write_codelist(file_id::UInt64, cl_name::String, symbol_list::String)::Cint
 * 向HDB文件中写入一个代码列表。一个代码列表即一个给定名称的代码集合，
 * 集合中的代码必须为文件中已存在的代码(通过write_codes接口写入过代码信息，
 * 或者通过write_items接口写入过数据记录)。
 *
 * @param file_id       文件句柄
 * @param cl_name       代码列表名称
 * @param symbol        代码列表，多个代码之间以逗号(,)分隔
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_write_codelist(file_id::UInt64, cl_name::String, symbol_list::String)::Cint
    errcode = ccall((:hdb_write_codelist,lib), Int32, (UInt64, Ptr{UInt8}, Ptr{UInt8}), file_id, cl_name, symbol_list)
end
export hdb_write_codelist

"""
    hdb_read_codetable(file_id::UInt64, cl_name::String)::Vector{HCodeInfo}
 * 读取代码表。
 *
 * @param file_id       文件句柄
 * @param cl_name       代码列表名称。为空指针或空字符串时读取
 *                      全市场所有代码信息，否则读取指定代码列表
 *                      中代码的代码信息。
 *
 * @return codes        代码信息数组，失败返回空。
"""
function hdb_read_codetable(file_id::UInt64, cl_name::String)::Vector{HCodeInfo}
    count_r = Ref{Cint}(0)
    errcode = ccall((:hdb_read_codetable,lib), Int32, (UInt64, Ptr{UInt8}, Ptr{HCodeInfo}, Ptr{Cint}), file_id, cl_name, C_NULL, count_r)
    if 0 == errcode
        codes = Vector{HCodeInfo}(undef, Int(count_r[]))
        errcode = ccall((:hdb_read_codetable,lib), Int32, (UInt64, Ptr{UInt8}, Ptr{HCodeInfo}, Ptr{Cint}), file_id, cl_name, codes, count_r)
        if 0 == errcode
            return codes
        end
    end
    return HCodeInfo[]
end
export hdb_read_codetable

"""
    hdb_read_codeinfo(file_id::UInt64, symbol::String)::Union{HCodeInfo,Nothing}
 * 读取指定代码的代码信息。
 *
 * @param file_id       文件句柄
 * @param symbol        标的代码。
 * @param code          代码信息，输出参数。
 *
 * @return code         成功返回代码信息，失败返回nothing
"""
function hdb_read_codeinfo(file_id::UInt64, symbol::String)
    codeinfo = Ref{HCodeInfo}()
    errcode = ccall((:hdb_read_codeinfo,lib), Int32, (UInt64, Ptr{UInt8}, Ptr{HCodeInfo}), file_id, symbol, codeinfo)
    if errcode == 0
        return codeinfo[]
    else
        return nothing
    end
end
export hdb_read_codeinfo

"""
    hdb_read_all_codelists(file_id::UInt64)::Vector{String}
 * 从HDB文件读取所有之前写入的代码列表。
 *
 * @param file_id       文件句柄
 *
 * @return cl_names     成功返回代码列表名称数组，失败返回空数组
"""
function hdb_read_all_codelists(file_id::UInt64)::Vector{String}
    count_r = Ref{Cint}(0)
    errcode = ccall((:hdb_read_all_codelists,lib), Int32, (UInt64, Ptr{Ptr{UInt8}}, Ptr{Cint}), file_id, C_NULL, count_r)
    if 0 == errcode
        cl_name = Vector{Ptr{UInt8}}(undef, Int(count_r[]))
        errcode = ccall((:hdb_read_all_codelists,lib), Int32, (UInt64, Ptr{Ptr{UInt8}}, Ptr{Cint}), file_id, cl_name, count_r)
        if 0 == errcode
            return unsafe_string.(cl_name)
        end
    end
    return String[]
end
export hdb_read_all_codelists

"""
    function hdb_open_read_task(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
 * 开启数据读取任务。
 *
 * @param file_id       文件句柄
 * @param symbol_list   代码列表，多个代码之间以逗号(,)分隔。
 *                      配置为空指针或空字符串时读取所有代码的数据
 *                      配置为 代码列表.* 时读取该代码列表中所有代码的数据
 * @param type_list     数据类型名列表，多个数据类型名之间以逗号(,)分隔。
 *                      为空字符串时读取所有数据类型的数据记录。
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点


 * @param offset        开始读取位置偏移。默认为0，当设置为大于0的值时，
 *                      将从该偏移指定位置的数据记录开始读取。
 *
 * @return              成功返回HDB数据读取任务句柄，失败返回0
"""
function hdb_open_read_task(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
    ccall((:hdb_open_read_task,lib), UInt64, (UInt64, Cint, Cint, Cint, Cint, Ptr{UInt8}, Ptr{UInt8}, Int64), file_id, begin_date, begin_time, end_date, end_time, symbol_list, type_list, offset)
end

"""
    function hdb_open_read_task(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
 * 开启数据读取任务。
 *
 * @param file_id       文件句柄
 * @param symbols       代码列表
 * @param types         数据类型名列表
 *                      为空字符串时读取所有数据类型的数据记录。
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点


 * @param offset        开始读取位置偏移。默认为0，当设置为大于0的值时，
 *                      将从该偏移指定位置的数据记录开始读取。
 *
 * @return              成功返回HDB数据读取任务句柄，失败返回0
"""
function hdb_open_read_task(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
    symbol_list = join(symbols,",")
    type_list = join(types,",")
    ccall((:hdb_open_read_task,lib), UInt64, (UInt64, Cint, Cint, Cint, Cint, Ptr{UInt8}, Ptr{UInt8}, Int64), file_id, begin_date, begin_time, end_date, end_time, symbol_list, type_list, offset)
end
export hdb_open_read_task

"""
    function hdb_read_items(task_id::UInt64, len::Integer)::Vector{HDataItem}
 * 从已打开的数据读取任务依次读取指定数量的数据记录。
 * 系统保证返回的数据记录严格时序递增。
 *
 * @param task_id       数据读取任务句柄
 * @param len           数据记录数量。
 *
 * @return items        成功返回数据记录数组，失败返回空数组
"""  
function hdb_read_items(task_id::UInt64, len::Integer)::Vector{HDataItem}
    count_r = Ref{Int32}(len)
    items = Vector{HDataItem}(undef, len)
    errcode = ccall((:hdb_read_items,lib), Int32, (UInt64, Ptr{HDataItem}, Ptr{Int32}), task_id, items, count_r)
    if errcode == 0 && count_r[] > 1 
        return items[1:count_r[]]
    end
    return HDataItem[]
end
export hdb_read_items

"""
    function hdb_close_read_task(task_id::UInt64)::Int32
 * 关闭给定数据读取任务。
 *
 * @param task_id       数据读取任务句柄
 *
 * @return              成功返回0，失败返回错误码
""" 
function hdb_close_read_task(task_id::UInt64)::Int32
    errcode = ccall((:hdb_close_read_task,lib), Int32, (UInt64, ), task_id)
    return errcode
end
export hdb_close_read_task
"""
    function hdb_calc_data_items_count(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)::Int64
 * 计算并返回满足指定读取条件的数据记录的数量。
 *
 * @param file_id       文件句柄
 * @param symbol_list   代码列表，多个代码之间以逗号(,)分隔。
 *                      配置为空指针或空字符串时读取所有代码的数据
 *                      配置为 代码列表.* 时读取该代码列表中所有代码的数据
 * @param type_list     数据类型名列表，多个数据类型名之间以逗号(,)分隔。
 *                      为空字符串时读取所有数据类型的数据记录。
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点

 *
 * @return              成功满足指定读取条件数据记录的数量，失败返回错误码。
"""
function hdb_calc_data_items_count(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)::Int64
    ccall((:hdb_calc_data_items_count,lib), Int64, (UInt64, Cint, Cint, Cint, Cint, Ptr{UInt8},
            Ptr{UInt8}), task_id, begin_date, begin_time, end_date, end_time, symbol_list, type_list)
end

"""
    function hdb_calc_data_items_count(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)
 * 计算并返回满足指定读取条件的数据记录的数量。
 *
 * @param file_id       文件句柄
 * @param symbols      代码列表，多个代码之间以逗号(,)分隔。
 *                      配置为空指针或空字符串时读取所有代码的数据
 *                      配置为 代码列表.* 时读取该代码列表中所有代码的数据
 * @param type_list     数据类型名列表，多个数据类型名之间以逗号(,)分隔。
 *                      为空字符串时读取所有数据类型的数据记录。
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点

 *
 * @return              成功满足指定读取条件数据记录的数量，失败返回错误码。
"""
function hdb_calc_data_items_count(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)::Int64
    symbol_list = join(symbols,",")
    type_list = join(types,",")
    ccall((:hdb_calc_data_items_count,lib), Int64, (UInt64, Cint, Cint, Cint, Cint, Ptr{UInt8},
            Ptr{UInt8}), task_id, begin_date, begin_time, end_date, end_time, symbol_list, type_list)
end
export hdb_calc_data_items_count

"""
    function hdb_last_error()
 * 获取当前线程最近一次API调用的错误码。
 *
 * @return              最近一次API调用的错误码
"""
function hdb_last_error()::Int32
    errcode = ccall((:hdb_last_error,lib), Int32, ())
    return errcode
end
export hdb_last_error

function trade_date(holidayfile::String, begin_date::Date, end_date::Date)::Vector{Date}
    info = ""   
    if isfile(holidayfile)
        f = open(holidayfile, "r")
        info = read(f,String)
    end
    lholiday = Date.(split(info,','))
    dt = Dates.Day(1)
    dates = Date[]
    while begin_date <= end_date
        if dayofweek(begin_date) <= 5 && !(begin_date in lholiday)
            push!(dates,begin_date)
        end
        begin_date = begin_date + dt
    end
    return dates
end
export trade_date

function next_trade_date(holidayfile::String, begin_date::Date)::Date
    info = ""   
    if isfile(holidayfile)
        f = open(holidayfile, "r")
        info = read(f,String)
    end
    lholiday = Date.(split(info,','))
    dt = Dates.Day(1)
    next_date = begin_date + dt
    for i in 1:50
        if dayofweek(next_date) <= 5 && !(next_date in lholiday)
            return next_date
        else
            next_date = next_date + dt
        end
    end
    return next_date
end
export next_trade_date

"""
    function hdb_open_client(host::String, port::String, username::String, 
         password::String, op_timeout::Integer = 15000)::UInt64
 * 打开HDB客户端，建立和服务端之间的连接，执行用户登陆等初始化操作。
 *
 * 注意：如果连接/登陆失败或连接建立后出现网络错误导致连接断开，任何后续
 * 操作都将返回网络错误。用户需要关闭当前客户端，打开新的HDB客户端。
 *
 * @param host           HDB服务端地址
 * @param port           HDB服务端监听端口
 * @param username       登陆用户名
 * @param pwd            登陆密码
 * @param op_timeout     任一操作超时时间(单位毫秒)
 *                       若操作超时，接口库将主动关闭当前连接
 *
 * @return               成功返回客户端句柄，失败返回0
"""
function hdb_open_client(host::String, port::String, username::String, 
         password::String, op_timeout::Integer = 15000)::UInt64
    db = ccall((:hdb_open_client, clientlib), UInt64, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}, Cint), host, port, username, password, op_timeout)
end
export hdb_open_client

"""
    function hdb_close_client(cid::UInt64)::Cint
 * 关闭HDB客户端。
 *
 * @param cid           HDB客户端句柄
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_close_client(cid::UInt64)::Cint
    errcode = ccall((:hdb_close_client, clientlib), Cint, (UInt64, ), cid)
end
export hdb_close_client

"""
    function hdb_client_open_file(cid::UInt64, path::String, len::Integer = 20)::Tuple{UInt64,Cint,Base.RefValue{HDataType},Vector{HDataType}}
 * 请求服务端打开给定路径的HDB文件。
 *
 * @param cid           HDB客户端句柄
 * @param path          文件路径，即相对于根目录的文件相对路径
 *                      当需要打开内存缓存数据文件时，文件路径需加上前缀memory/
 * @param ci_type       代码信息数据类型定义，输出参数。
 * @param data_types    数据类型定义数组，输出参数。
 * @param count         数据类型定义数量。
 *                      输入时为输入的data_types数组长度，输出为返回的数据类型数量。
 *                      若输入时该值比需要返回的数量小时，接口返回HRetCode_NotEnoughMemory
 *
 * @return              成功返回HDB客户端文件句柄，失败返回0
"""

function hdb_client_open_file(cid::UInt64, path::String, len::Integer = 20)::Tuple{UInt64,Cint,Base.RefValue{HDataType},Vector{HDataType}}
    ci_type_r = Ref{HDataType}()
    data_types = Vector{HDataType}(undef,len)
    type_num_r = Ref{Cint}(len)
    fileid = ccall((:hdb_client_open_file, clientlib), UInt64, (UInt64, Ptr{UInt8}, Ptr{HDataType}, Ptr{HDataType}, Ptr{Cint}), cid, path, ci_type_r, data_types, type_num_r)
    type_num = type_num_r[]
    return fileid, type_num, ci_type_r, data_types    
end
export hdb_client_open_file                                     

"""
    function hdb_client_close_file(file_id::UInt64)::Cint
 * 请求服务端关闭HDB文件。
 *
 * @param file_id       HDB客户端文件句柄
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_client_close_file(file_id::UInt64)::Cint
    errcode = ccall((:hdb_client_close_file, clientlib), Cint, (UInt64, ), file_id)
end
export hdb_client_close_file

"""
 * 从服务端读取代码表。
 *
 * @param file_id       客户端文件句柄
 * @param cl_name       代码列表名称。为空指针或空字符串时读取
 *                      全市场所有代码信息，否则读取指定代码列表
 *                      中代码的代码信息。
 * @param no_data       服务端返回数据时是否跳过data字段
 * @param codes         代码信息数组，输出参数。
 *                      设置为空指针时不返回代码信息，仅通过count字段返回代码信息数量
 * @param count         代码信息数量。
 *                      输入时为输入的codes数组长度，输出为返回的代码信息数量。
 *                      当输入时该值比需要返回的数量小时，接口返回HRetCode_NotEnoughMemory
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_client_read_codetable(file_id::UInt64, cl_name::String, no_data::Bool=false)::Vector{HCodeInfo}
    if no_data
        cno_data = UInt8(1)
    else
        cno_data = UInt8(0)
    end
    count_r = Ref{Cint}(0)
    errcode = ccall((:hdb_client_read_codetable, clientlib), Cint, (UInt64, Ptr{UInt8}, UInt8, Ptr{HCodeInfo}, Ptr{Cint}), file_id, cl_name, cno_data, C_NULL, count_r)
    if 0 == errcode
        codes = Vector{HCodeInfo}(undef, Int(count_r[]))
        errcode = ccall((:hdb_client_read_codetable, clientlib), Cint, (UInt64, Ptr{UInt8}, UInt8, Ptr{HCodeInfo}, Ptr{Cint}), file_id, cl_name, cno_data, codes, count_r)
        if 0 == errcode
            return codes
        end
    end
    return HCodeInfo[]    
end
export hdb_client_read_codetable


"""
    hdb_read_codeinfo(file_id::UInt64, symbol::String)::Union{HCodeInfo,Nothing}
 * 从服务端读取指定代码的代码信息。
 *
 * @param file_id       文件句柄
 * @param symbol        标的代码。
 * @param code          代码信息，输出参数。
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_client_read_codeinfo(file_id::UInt64, symbol::String)
    codeinfo = Ref{HCodeInfo}()
    errcode = ccall((:hdb_client_read_codeinfo,clientlib), Int32, (UInt64, Ptr{UInt8}, Ptr{HCodeInfo}), file_id, symbol, codeinfo)
    if errcode == 0
        return codeinfo[]
    else
        return nothing
    end
end
export hdb_client_read_codeinfo                                     

"""
    function hdb_client_read_all_codelists(file_id::UInt64)::Vector{String}
 * 从服务端读取指定HDB文件之前写入的所有代码列表。
 *
 * @param file_id       文件句柄
 * @param cl_names      代码列表名称数组，输出参数
 *                      设置为空指针时不返回代码列表名称，仅通过count字段返回列表名称数量
 * @param count         代码列表数量
 *                      输入时为输入的cl_names数组长度，输出为返回的代码列表数量。
 *                      当输入时该值比需要返回的数量小时，接口返回HRetCode_NotEnoughMemory
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_client_read_all_codelists(file_id::UInt64)::Vector{String}
    count_r = Ref{Cint}(0)
    errcode = ccall((:hdb_client_read_all_codelists, clientlib), Int32, (UInt64, Ptr{Ptr{UInt8}}, Ptr{Cint}), file_id, C_NULL, count_r)
    if 0 == errcode
        cl_name = Vector{Ptr{UInt8}}(undef, Int(count_r[]))
        errcode = ccall((:hdb_client_read_all_codelists, clientlib), Int32, (UInt64, Ptr{Ptr{UInt8}}, Ptr{Cint}), file_id, cl_name, count_r)
        if 0 == errcode
            return unsafe_string.(cl_name)
        end
    end
    return String[]
end
export hdb_client_read_all_codelists                                          

"""
    hdb_client_open_read_task(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
 * 请求服务端开启数据读取任务。
 *
 * @param file_id       文件句柄
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点
 * @param symbol_list   代码列表，多个代码之间以逗号(,)分隔。
 *                      配置为空指针或空字符串时读取所有代码的数据
 *                      配置为 代码列表.* 时读取该代码列表中所有代码的数据
 * @param type_list     数据类型名列表，多个数据类型名之间以逗号(,)分隔。
 * @param offset        开始读取位置偏移。默认为0，当设置为大于0的值时，
 *                      将从该偏移指定位置的数据记录开始读取。
 *
 * @return              成功返回客户端HDB数据读取任务句柄，失败返回0
"""
function hdb_client_open_read_task(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
    ccall((:hdb_client_open_read_task, clientlib), UInt64, (UInt64, Cint, Cint, Cint, Cint, Ptr{UInt8}, Ptr{UInt8}, Int64), file_id, begin_date, begin_time, end_date, end_time, symbol_list, type_list, offset)
end

"""
    hdb_client_open_read_task(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
 * 请求服务端开启数据读取任务。
 *
 * @param file_id       文件句柄
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点
 * @param symbol_list   代码列表，多个代码之间以逗号(,)分隔。
 *                      配置为空指针或空字符串时读取所有代码的数据
 *                      配置为 代码列表.* 时读取该代码列表中所有代码的数据
 * @param type_list     数据类型名列表，多个数据类型名之间以逗号(,)分隔。
 * @param offset        开始读取位置偏移。默认为0，当设置为大于0的值时，
 *                      将从该偏移指定位置的数据记录开始读取。
 *
 * @return              成功返回客户端HDB数据读取任务句柄，失败返回0
"""
function hdb_client_open_read_task(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0, 
        offset::Integer=0)::UInt64
    symbol_list = join(symbols,",")
    type_list = join(types,",")
    hdb_client_open_read_task(file_id, symbol_list, type_list; begin_date=begin_date,
    begin_time=begin_time, end_date=end_date, end_time=end_time, offset=offset)
end
export hdb_client_open_read_task

"""
    function hdb_client_read_items(task_id::UInt64, len::Integer)::Vector{HDataItem}
 * 从服务端已打开的数据读取任务依次读取指定数量的数据记录。
 * 系统保证返回的数据记录严格时序递增。
 *
 * @param task_id       客户端数据读取任务句柄
 * @param items         数据记录数组，输出参数。
 * @param count         数据记录数量。
 *                      输入时为输入的items数组长度，输出为返回的记录数量。
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_client_read_items(task_id::UInt64, len::Integer)::Vector{HDataItem}
    count_r = Ref{Int32}(len)
    items = Vector{HDataItem}(undef, len)
    errcode = ccall((:hdb_client_read_items, clientlib), Int32, (UInt64, Ptr{HDataItem}, Ptr{Int32}), task_id, items, count_r)
    if errcode == 0 && count_r[] > 1 
        return items[1:count_r[]]
    end
    return HDataItem[]
end
export hdb_client_read_items

"""
    
 * 请求服务端关闭给定数据读取任务。
 *
 * @param task_id       客户端数据读取任务句柄
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_client_close_read_task(task_id::UInt64)::Int32
    errcode = ccall((:hdb_client_close_read_task, clientlib), Int32, (UInt64, ), task_id)
    return errcode
end
export hdb_client_close_read_task

"""
    function hdb_client_calc_data_items_count(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)::Int64
 * 计算并返回满足指定读取条件的数据记录的数量。
 *
 * @param file_id       文件句柄
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点
 * @param symbol_list   代码列表，多个代码之间以逗号(,)分隔。
 *                      配置为空指针或空字符串时读取所有代码的数据
 *                      配置为 代码列表.* 时读取该代码列表中所有代码的数据
 * @param type_list     数据类型名列表，多个数据类型名之间以逗号(,)分隔。
 *                      为空字符串时读取所有数据类型的数据记录。
 *
 * @return              成功满足指定读取条件数据记录的数量，失败返回错误码。
"""
function hdb_client_calc_data_items_count(file_id::UInt64, symbol_list::String, type_list::String; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)::Int64
    ccall((:hdb_client_calc_data_items_count, clientlib), Int64, (UInt64, Cint, Cint, Cint, Cint, Ptr{UInt8},
            Ptr{UInt8}), task_id, begin_date, begin_time, end_date, end_time, symbol_list, type_list)
end

"""
    function hdb_client_calc_data_items_count(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)
 * 计算并返回满足指定读取条件的数据记录的数量。
 *
 * @param file_id       文件句柄
 * @param symbols      代码列表，多个代码之间以逗号(,)分隔。
 *                      配置为空指针或空字符串时读取所有代码的数据
 *                      配置为 代码列表.* 时读取该代码列表中所有代码的数据
 * @param type_list     数据类型名列表，多个数据类型名之间以逗号(,)分隔。
 *                      为空字符串时读取所有数据类型的数据记录。
 * @param begin_date    开始日期(YYYYmmdd)
 * @param begin_time    开始时间(HHMMSSsss)
 * @param end_date      结束日期(YYYYmmdd)，配置为0时不限制结束时间
 * @param end_time      结束时间(HHMMSSsss)，包含该时间点

 *
 * @return              成功满足指定读取条件数据记录的数量，失败返回错误码。
"""
function hdb_client_calc_data_items_count(file_id::UInt64, symbols::Union{Vector{String},Tuple{Vararg{String}}}, 
        types::Union{Vector{String},Tuple{Vararg{String}}}; 
        begin_date::Integer=0, begin_time::Integer=0, end_date::Integer=0, end_time::Integer=0)::Int64
    symbol_list = join(symbols,",")
    type_list = join(types,",")
    hdb_client_calc_data_items_count(file_id, symbol_list, type_list; 
        begin_date=begin_date, begin_time=begin_time, end_date=end_date, 
        end_time=end_time)
end
export hdb_client_calc_data_items_count

"""
    
 * 从服务端读取指定文件从给定偏移开始的一段数据内容。
 *
 * @param cid           HDB客户端句柄
 * @param path          文件相对于HDB根目录的相对路径
 * @param offset        文件读取开始位置
 * @param data          读取的文件内容，输出参数
 * @param size          文件数据内容长度
 *                      输入时为需要读取的数据内容长度，输出时为实际返回数据内容长度。
 *                      一次请求读取的长度不能超过HDB_MAX_CLIENT_FILE_READ_SIZE
 * @param use_compress  是否对数据内容进行压缩传输，默认开启压缩。
 *
 * @return              成功返回0，失败返回错误码
"""
function hdb_client_read_file(cid::UInt64, path::String, offset::Integer, len::Integer, user_compress::Bool=true) 
    if user_compress
        cuser_compress = UInt8(1)
    else
        cuser_compress = UInt8(0)
    end
    cdata = Vector{UInt8}(undef, len)
    len_r = Ref{Cint}(len)
    errcode = ccall((:hdb_client_read_file, clientlib), Int64, (UInt64, Ptr{UInt8}, Int64, Ptr{UInt8}, Ptr{Cint}, UInt8), cid, path, offset, cdata, len, cuser_compress)
    if 0 == errcode && len_r[] > 1
        return cdata[1:len_r[]]
    end
    return UInt8[]
end
export hdb_client_read_file

"""
    
 * 获取服务端指定子文件夹下的文件列表。
 *
 * @param cid           HDB客户端句柄
 * @param folder        文件相对于HDB根目录的子文件夹路径
 * @param file_list     文件列表,多个文件名之间用逗号(,)分隔
 *
 * @return              成功返回0，失败返回错误码

HDB_API int hdb_client_get_folder_files(hdb_id_t cid, const char* folder,
                                        const char** file_list);
"""

"""
    function hdb_client_last_error()::Int32
 * 获取当前线程最近一次客户端API调用的错误码。
 *
 * @return              最近一次客户端API调用的错误码
"""
function hdb_client_last_error()::Int32
    errcode = ccall((:hdb_client_last_error, clientlib), Int32, ())
    return errcode
end
export hdb_client_last_error


end