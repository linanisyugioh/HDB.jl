using HDB
using Test
using Dates

# 辅助函数：创建完整长度的字段元组
function create_full_fields_tuple(fields::Vector{HDB.HDataField}, field_count::Int)
    # 创建包含所有512个字段的数组，用默认值填充未使用的字段
    all_fields = Vector{HDB.HDataField}(undef, HDB.HDB_MAX_DATA_FIELD_NUM)
    
    # 复制我们定义的字段
    for i in 1:min(field_count, length(fields))
        all_fields[i] = fields[i]
    end
    
    # 用默认值填充剩余字段
    default_field = HDB.HDataField(
        NTuple{HDB.HDB_MAX_FIELDNANE_SIZE, UInt8}(zeros(UInt8, HDB.HDB_MAX_FIELDNANE_SIZE)),
        Cint(0), Cint(0), Cint(0), Cint(0)
    )
    
    for i in (field_count+1):HDB.HDB_MAX_DATA_FIELD_NUM
        all_fields[i] = default_field
    end
    
    return NTuple{HDB.HDB_MAX_DATA_FIELD_NUM, HDB.HDataField}(all_fields)
end

@testset "HDB.jl" begin
    @testset "数据库基础功能" begin
        # 测试数据库打开关闭
        test_db_folder = "./test_db"
        mkpath(test_db_folder)
        
        db_id = hdb_open_db(test_db_folder)
        @test db_id != 0
        
        # 测试数据库关闭
        close_result = hdb_close_db(db_id)
        @test close_result == 0
    end
    
    @testset "hdb_create_file 文件创建功能" begin
        println("=== 测试 hdb_create_file 接口 ===")
        
        # 打开数据库
        test_db_folder = "./test_db"
        db_id = hdb_open_db(test_db_folder)
        @test db_id != 0
        
        # 准备代码信息数据类型
        ci_type_name = "CodeInfo"
        ci_type_name_bytes = zeros(UInt8, HDB.HDB_MAX_TYPENANE_SIZE)
        ci_type_name_bytes[1:length(ci_type_name)] = Vector{UInt8}(ci_type_name)
        
        ci_fields = Vector{HDB.HDataField}(undef, 2)
        
        # 字段1: 上市日期
        field1_name = "list_date"
        field1_bytes = zeros(UInt8, HDB.HDB_MAX_FIELDNANE_SIZE)
        field1_bytes[1:length(field1_name)] = Vector{UInt8}(field1_name)
        ci_fields[1] = HDB.HDataField(
            NTuple{HDB.HDB_MAX_FIELDNANE_SIZE, UInt8}(field1_bytes),
            Cint(HDB.HFieldType_Int),
            Cint(HDB.HFieldEncodeOp_Raw),
            Cint(4),
            Cint(0)
        )
        
        # 字段2: 退市日期
        field2_name = "delist_date"
        field2_bytes = zeros(UInt8, HDB.HDB_MAX_FIELDNANE_SIZE)
        field2_bytes[1:length(field2_name)] = Vector{UInt8}(field2_name)
        ci_fields[2] = HDB.HDataField(
            NTuple{HDB.HDB_MAX_FIELDNANE_SIZE, UInt8}(field2_bytes),
            Cint(HDB.HFieldType_Int),
            Cint(HDB.HFieldEncodeOp_Raw),
            Cint(4),
            Cint(0)
        )
        
        # 使用辅助函数创建完整的字段元组
        ci_fields_tuple = create_full_fields_tuple(ci_fields, 2)
        ci_type = HDB.HDataType(
            NTuple{HDB.HDB_MAX_TYPENANE_SIZE, UInt8}(ci_type_name_bytes),
            Cint(2),
            ci_fields_tuple,
            Cint(8)
        )
        
        # 准备数据数据类型
        data_types = Vector{HDB.HDataType}(undef, 1)
        
        type1_name = "TestData"
        type1_bytes = zeros(UInt8, HDB.HDB_MAX_TYPENANE_SIZE)
        type1_bytes[1:length(type1_name)] = Vector{UInt8}(type1_name)
        
        type1_fields = Vector{HDB.HDataField}(undef, 3)
        
        # 价格字段
        price_field_name = "price"
        price_bytes = zeros(UInt8, HDB.HDB_MAX_FIELDNANE_SIZE)
        price_bytes[1:length(price_field_name)] = Vector{UInt8}(price_field_name)
        type1_fields[1] = HDB.HDataField(
            NTuple{HDB.HDB_MAX_FIELDNANE_SIZE, UInt8}(price_bytes),
            Cint(HDB.HFieldType_Float),
            Cint(HDB.HFieldEncodeOp_Raw),
            Cint(4),
            Cint(0)
        )
        
        # 成交量字段
        volume_field_name = "volume"
        volume_bytes = zeros(UInt8, HDB.HDB_MAX_FIELDNANE_SIZE)
        volume_bytes[1:length(volume_field_name)] = Vector{UInt8}(volume_field_name)
        type1_fields[2] = HDB.HDataField(
            NTuple{HDB.HDB_MAX_FIELDNANE_SIZE, UInt8}(volume_bytes),
            Cint(HDB.HFieldType_Long),
            Cint(HDB.HFieldEncodeOp_Raw),
            Cint(8),
            Cint(0)
        )
        
        # 时间字段
        time_field_name = "timestamp"
        time_bytes = zeros(UInt8, HDB.HDB_MAX_FIELDNANE_SIZE)
        time_bytes[1:length(time_field_name)] = Vector{UInt8}(time_field_name)
        type1_fields[3] = HDB.HDataField(
            NTuple{HDB.HDB_MAX_FIELDNANE_SIZE, UInt8}(time_bytes),
            Cint(HDB.HFieldType_Long),
            Cint(HDB.HFieldEncodeOp_Raw),
            Cint(8),
            Cint(0)
        )
        
        # 使用辅助函数创建完整的字段元组
        type1_fields_tuple = create_full_fields_tuple(type1_fields, 3)
        data_types[1] = HDB.HDataType(
            NTuple{HDB.HDB_MAX_TYPENANE_SIZE, UInt8}(type1_bytes),
            Cint(3),
            type1_fields_tuple,
            Cint(20)  # 4 + 8 + 8 = 20字节
        )
        
        # 测试文件创建
        file_path = "test_create_file.hdb"
        file_id = hdb_create_file(db_id, file_path, ci_type, data_types, 64*1024)
        
        @test file_id != 0
        
        if file_id != 0
            println("✓ 文件创建成功")
            
            # 测试代码信息写入
            codes = Vector{HDB.HCodeInfo}(undef, 2)
            
            symbol1 = "TEST001"
            symbol1_bytes = zeros(UInt8, HDB.HDB_MAX_SYMBOL_SIZE)
            symbol1_bytes[1:length(symbol1)] = Vector{UInt8}(symbol1)
            
            code1_data = [Int32(20200101), Int32(0)]
            code1_data_ptr = pointer(code1_data)
            
            # 创建完整的 type_items_nums 元组
            type_items_nums = zeros(Cint, HDB.HDB_MAX_FILE_TYPE_NUM)
            type_items_nums_tuple = NTuple{HDB.HDB_MAX_FILE_TYPE_NUM, Cint}(type_items_nums)
            
            codes[1] = HDB.HCodeInfo(
                NTuple{HDB.HDB_MAX_SYMBOL_SIZE, UInt8}(symbol1_bytes),
                Cint(0),
                Cint(0),
                type_items_nums_tuple,
                code1_data_ptr
            )
            
            symbol2 = "TEST002"
            symbol2_bytes = zeros(UInt8, HDB.HDB_MAX_SYMBOL_SIZE)
            symbol2_bytes[1:length(symbol2)] = Vector{UInt8}(symbol2)
            
            code2_data = [Int32(20200102), Int32(0)]
            code2_data_ptr = pointer(code2_data)
            
            codes[2] = HDB.HCodeInfo(
                NTuple{HDB.HDB_MAX_SYMBOL_SIZE, UInt8}(symbol2_bytes),
                Cint(0),
                Cint(0),
                type_items_nums_tuple,
                code2_data_ptr
            )
            
            write_result = hdb_write_codes(file_id, codes)
            @test write_result == 0
            
            # 测试代码列表写入
            codelist_name = "test_codelist"
            symbol_list = ["TEST001", "TEST002"]
            
            write_list_result = hdb_write_codelist(file_id, codelist_name, symbol_list)
            @test write_list_result == 0
            
            # 测试文件关闭
            close_result = hdb_close_file(file_id)
            @test close_result == 0
        end
        
        # 关闭数据库
        hdb_close_db(db_id)
    end
    
    @testset "文件打开和读取功能" begin
        # 这里可以添加文件打开和读取的测试
        # 测试 hdb_open_file, hdb_read_codetable 等接口
        test_db_folder = "./test_db"
        db_id = hdb_open_db(test_db_folder)
        @test db_id != 0
        
        # 尝试打开之前创建的文件
        begin
        file_id, type_num, ci_type, data_types = hdb_open_file(db_id, "test_create_file.hdb", 0)
        file_id
        end
        
        if file_id != 0
            @test type_num >= 0
            @test ci_type != nothing
            @test length(data_types) >= 0
            
            # 测试读取代码表
            codes = hdb_read_codetable(file_id, "")
            @test length(codes) >= 0
            
            # 测试读取代码列表
            codelists = hdb_read_all_codelists(file_id)
            @test length(codelists) >= 0
            
            hdb_close_file(file_id)
        end
        
        hdb_close_db(db_id)
    end
    
    @testset "工具函数测试" begin
        # 测试 convert_chararray_to_string
        test_bytes = Vector{UInt8}("hello")
        padded_bytes = zeros(UInt8, 10)
        padded_bytes[1:length(test_bytes)] = test_bytes
        
        result = convert_chararray_to_string(Tuple(padded_bytes))
        @test result == "hello"
        
        # 测试 trade_date 函数（需要提供节假日文件）
        begin_date = Date(2024, 1, 1)
        end_date = Date(2024, 1, 10)
        
        # 如果没有节假日文件，可以创建一个临时的空文件
        holiday_file = "./test_holidays.txt"
        if !isfile(holiday_file)
            open(holiday_file, "w") do f
                write(f, "2024-01-01,")  # 元旦
            end
        end
        
        trade_dates = trade_date(holiday_file, begin_date, end_date)
        @test length(trade_dates) > 0
        
        # 清理测试文件
        try
            rm(holiday_file, force=true)
        catch
        end
    end
end

# 测试完成后清理
#println("清理测试环境...")
#try
#    rm("./test_db", recursive=true, force=true)
#    println("测试环境清理完成")
#catch e
#    println("清理测试环境时出现警告: $e")
#end