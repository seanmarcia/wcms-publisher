module PolicyPermissions

  private

  def program_editor?
    user.has_role?(:'program-editor')
  end

end
