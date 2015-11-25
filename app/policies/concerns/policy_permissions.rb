module PolicyPermissions

  def program_editor?
    user.has_role?(:'program-editor')
  end

  def media_editor?
    user.has_role?(:media_editor) || user.admin? || user.developer?
  end
end
