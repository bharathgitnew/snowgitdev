def get_file_format_info(engine, file_format):
    file_format_data = engine.execute("DESCRIBE FILE FORMAT {file_format}".format(file_format=file_format))
    file_format = pd.DataFrame.from_records(iter(file_format_data),
                                            columns=[x[0] for x in file_format_data.description])

    delimiter = (
        list(file_format
             .loc[file_format['property'] == 'RECORD_DELIMITER']['property_value'])[0]
            .encode().decode('unicode_escape')
    )

    encoding = list(file_format
                .loc[file_format['property'] == 'ENCODING']['property_value'])[0]

    skip_header = int(list(file_format
                           .loc[file_format['property'] == 'SKIP_HEADER']['property_value'])[0])

    return {'delimiter': delimiter, 'encoding': encoding, 'skip_header': skip_header}


def format_stage_type(stage_type, stage_name, table):
    if stage_type == 'NAMED':
        return '@' + stage_name + "/" + table
    elif stage_type == 'TABLE':
        return '@%' + stage_name
    elif stage_type == 'USER':
        return '@~'
