User.class_eval do
  [:admin, :developer, :faculty, :student, :employee, :alumnus, :student_worker, :trustee, :volunteer].each do |affl|
    define_method "#{affl}?" do
      has_role? affl
    end
  end

  # This actually looks up the person by their biola_id number
  def find_person
    @user_person ||= Person.where(biola_id: biola_id).first
  end
end
