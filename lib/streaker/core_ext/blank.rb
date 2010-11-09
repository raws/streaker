class String
  def blank?
    self !~ /\S/
  end
end

class NilClass
  def blank?
    true
  end
end
