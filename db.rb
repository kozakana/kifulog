class Slog
  class DB
    def initialize start_date, end_date, dataset_name, table_name, opt={}
      @bigquery = Google::Cloud::Bigquery.new(
        {
          keyfile: "./API_key.json"
        }.merge(opt)
      )
    
      # http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-bigquery/v0.29.0/google/cloud/bigquery
      @ds_name = dataset_name
      @tb_name = table_name
      @start_date = format_date(start_date || today)
      @end_date = format_date(end_date || today)
    end

    def today
      Date.today.strftime("%Y%m%d")
    end

    def game_list
      sql = "SELECT game_code, MIN(moved_at) AS start_date FROM #{@ds_name}.#{@tb_name} WHERE _PARTITIONTIME BETWEEN TIMESTAMP('#{@start_date}') AND TIMESTAMP('#{@end_date}') GROUP BY game_code LIMIT 1000"
      p sql
      @bigquery.query sql
    end

    def game game_code
      sql = "SELECT * FROM #{@ds_name}.#{@tb_name} WHERE game_code = '#{game_code}' AND _PARTITIONTIME BETWEEN TIMESTAMP('#{@start_date}') AND TIMESTAMP('#{@end_date}') LIMIT 1000"
      @bigquery.query sql
    end

    def castle name
      regex =
        case name
        when 'mino'
          '(.{45}D.{8}-EH.{6}FAH.{6}G-(H.{6}|-H.{5})|(.{6}h|.{5}h-)-g.{6}haf.{6}he-.{8}d)'
        end
      sql = "select * from #{@ds_name}.#{@tb_name} where REGEXP_CONTAINS(position, '#{regex}') AND _PARTITIONTIME BETWEEN TIMESTAMP('#{@start_date}') AND TIMESTAMP('#{@end_date}') LIMIT 1000"
      states = @bigquery.query sql
      games =
        states.group_by do |state|
          state[:game_code]
        end
      games.map do |game_code, sts|
        sts.min_by do |st|
          st[:no]
        end
      end
    end

    def format_date date_str
      date_arr = [date_str[0..3], date_str[4..5], date_str[6..7]]
      date = date_arr.join('-')
      unless date.match(/\d{4}-[01]\d-[0-3]\d/)
        raise ArgumentError.new("Wrong date format")
      end
      date
    end
  end
end
