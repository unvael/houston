Template.document_view.helpers
  collection_name: -> Session.get('collection_name')
  adminHide: -> if Session.get('admin_should_show') then '' else 'hide'
  fields: ->
    document = get_collection().findOne _id: Session.get('document_id')
    unless document
      try
        document = get_collection().findOne _id: new Meteor.Collection.ObjectID(Session.get('document_id'))
      catch error
        console.log error
    (field_name: key, field_value: value for key, value of document)
  field_is_id: -> @field_name is '_id'

get_collection = -> window["inspector_#{Session.get('collection_name')}"]

Template.document_view.events
  'click .save': (e) ->
    e.preventDefault()
    old_object = get_collection().findOne _id: Session.get('document_id')
    update_dict = {}
    for field in $('.field')
      unless field.name is '_id'
        update_dict[field.name] = if typeof(old_object[field.name]) == 'number'
            parseFloat(field.value)
          else
            field.value
    Meteor.call("admin_#{Session.get('collection_name')}_update",
      Session.get('document_id'), $set: update_dict)
    Session.set('admin_should_show', true)
    setTimeout (->
      Session.set('admin_should_show', false)
    ), 1500
