```@meta
CurrentModule = HDB
```

# HDB

Documentation for [HDB](https://github.com/linanisyugioh/HDB.jl).

```@index
```

```@autodocs
Modules = [HDB]
folder = "Z:/hdb_data/"
db_id = hdb_open_db(folder)
flags = 0
file = "marketdata/tick_20251107"
file_id = hdb_open_file(db_id, file, flags)[1]
items = hdb_read_codetable(file_id, "ZLHY")
hdb_close_file(file_id)
hdb_close_db(db_id)
```
