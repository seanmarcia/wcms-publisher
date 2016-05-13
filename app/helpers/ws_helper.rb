module WsHelper

  def permission_to_edit?(obj, editable)
    policy(obj).can_change?(editable)
  end

  def wcms_source?(element)
    if element.respond_to? :ws_source
      element.ws_source == 'WCMS' || element.ws_source == 'WCMS-Music'
    elsif element.respond_to? :[]
      element['source'] == 'WCMS' || element['source'] == 'WCMS-Music'
    end
  end
end
