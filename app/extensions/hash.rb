Hash.class_eval do

  def set_modifier(user)
    if user
      self.tap { |h| h[:modifier_id] = user.id.to_s }
    else
      self
    end
  end

end
