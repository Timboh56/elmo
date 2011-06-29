class SearchToken
  def initialize(str, klass)
    @str = str
    @klass = klass
  end
  def sql
    # if this token is a boolean operator, just echo it back
    return @str if %w[and or not].include?(@str)
    
    # get the field spec from the target class
    field_spec = @klass.search_fields
    
    # if this token begins or ends with a parenth, save it.
    @str.gsub!(/^(\()/, "")
    oparenth = $1 || ""
    @str.gsub!(/(\))$/, "")
    cparenth = $1 || ""
    
    # if this token contains a qualifier
    if @str.match(/^(\w+):(.+)$/)
      qualifier, term = $1.to_sym, $2
      # raise an error if the qualifier is invalid
      raise SearchError.new("Invalid search qualifier '#{qualifier}'") unless field_spec[qualifier]
      fields = [qualifier]
    else
      # else, search default fields (get all fields with default param set to true)
      fields = field_spec.reject{|k,v| !v[:default]}.keys
      term = @str
    end
    
    # if the term is a regular expression, set a flag and remove the /'s
    if term.match(/\/(.+)\//)
      raise SearchError.new("Regular expressions not allowed for #{fields.first}") unless field_spec[fields.first][:regexp]
      regexp = true
      term = $1
    else
      regexp = false
    end
    
    # for each field, create a fragment
    fragments = []
    fields.each do |field|
      lhs, op, rhs = @klass.query_fragment(field, term)
      # if the term is a regexp, the op must be 'rlike', so override it
      if regexp
        # get rid of the %'s if the op was 'like'
        rhs.gsub!(/(^%|%$)/, "") if op == "like"
        op = "rlike"
      end
      
      fragments << sanitize("#{lhs} #{op} ?", rhs)
    end
    
    # join fragments with 'or' (note this is only for one token.. actual boolean operators are separate)
    oparenth + "(" + fragments.join(' or ') + ")" + cparenth
  end
  def sanitize(*args)
    ActiveRecord::Base.__send__(:sanitize_sql, args, '')
  end
end