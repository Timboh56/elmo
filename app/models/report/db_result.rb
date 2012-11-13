# models the result rows returned by the db from the query
class Report::DbResult
  attr_reader :rows
  
  def initialize(rows)
    @rows = rows

    # Mysql::Date doesn't seem to implement == properly so convert to string if we see one
    rows.each_with_index do |row, r|
      row.attributes.each do |key, value|
        if value.is_a?(Mysql::Time)
          rows[r][key] = value.to_s
        end
      end
    end
    
    # debug print rows
    #rows.each{|row| pp row.attributes}
  end
  
  # extracts unique tuples defined by the col names given in cols
  def extract_unique_tuples(*cols)
    # use a hash to make it fast
    tuple_hash = {}
    unique_tuples = []
    rows.each do |row|
      # get the tuple for this row
      tuple = cols.collect{|c| row[c]}
      
      # check if we've already seen this one
      unless tuple_hash[tuple]
        unique_tuples << tuple
        tuple_hash[tuple] = true
      end
    end
    
    return unique_tuples
  end
end