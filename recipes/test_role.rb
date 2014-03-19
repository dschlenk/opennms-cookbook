opennms_group "rolegroup" do
  comments "pocket protectors and such"
  users ['admin']
  duty_schedules ['MoTuWeThFrSaSu800-1700']
end 

# all options - only description is optional
opennms_role "chefrole" do
  membership_group "rolegroup"
  supervisor "admin"
  description "testing role creation from chef"
end

# example of specific
opennms_role_schedule "specific" do
  role_name "chefrole"
  username "admin"
  type "specific"
  times [{'begins' => '20-Mar-2014 00:00:00', 'ends' => '20-Mar-2014 11:00:00'}, {'begins' => '21-Mar-2014 15:00:00', 'ends' => '21-Mar-2014 23:00:00'}]
end

# example of daily
opennms_role_schedule "daily" do
  role_name "chefrole"
  username "admin"
  type "daily"
  times [{'begins' => '08:00:00', 'ends' => '09:00:00' }]
end

# example of weekly
opennms_role_schedule "weekly" do
  role_name "chefrole"
  username "admin"
  type "weekly"
  times [{'begins' => '08:00:00', 'ends' => '17:00:00', 'day' => 'monday'}, {'begins' => '09:00:00', 'ends' => '18:00:00', 'day' => 'tuesday'}]
end

# example of monthly
opennms_role_schedule "monthly" do
  role_name "chefrole"
  username "admin"
  type "monthly"
  times [{'begins' => '22:00:00', 'ends' => '23:00:00', 'day' => '1'}, {'begins' => '21:00:00', 'ends' => '23:00:00', 'day' => '15'}]
end
