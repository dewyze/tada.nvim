-- Every kind of entry, in the order a line is offered to them.
-- The first kind that can read the line owns it, so order carries meaning:
-- a box with no text is a placeholder before it is a todo, and a boxed line
-- ending in a colon is a todo before it is a topic.
return {
  require("tada.placeholder"),
  require("tada.todo"),
  require("tada.topic"),
  require("tada.list_item"),
  require("tada.note"),
  require("tada.metadata"),
  require("tada.comment"),
  require("tada.blank"),
  require("tada.text"),
}
