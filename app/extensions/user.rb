User.class_eval do
  [:faculty, :student, :employee, :alumnus, :student_worker, :trustee, :volunteer].each do |affl|
    define_method "#{affl}?" do
      has_role? affl
    end
  end

  # This actually looks up the person by their biola_id number
  def find_person
    @user_person ||= Person.where(biola_id: biola_id).first
  end

  def tracking_id
    # Warning: Changing this will cause duplicate records in Intercom
    Digest::MD5.hexdigest(biola_id.to_s)
  end

  def has_published_bio?
    BioEdition.published.where(person_id: person.id).count > 1
  end
end

