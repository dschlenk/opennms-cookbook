module Provision
  def foreign_id_gen
    t = Time.new
    "#{t.to_i}#{t.usec}"
  end
end
