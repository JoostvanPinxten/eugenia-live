(function() {

  grumble.Toolbox = (function() {

    Toolbox.name = 'Toolbox';

    function Toolbox() {}

    Toolbox.prototype.install = function() {
      this.createTools();
      this.reactToToolSelection();
      return this.reactToToolConfiguration();
    };

    Toolbox.prototype.createTools = function() {
      return grumble.tools = {
        node: new grumble.NodeTool(),
        select: new grumble.SelectTool(),
        link: new grumble.LinkTool()
      };
    };

    Toolbox.prototype.reactToToolSelection = function() {
      return $('body').on('click', 'a[data-tool]', function(event) {
        var tool, tool_name;
        tool_name = $(this).attr('data-tool');
        tool = grumble.tools[tool_name];
        if (tool) {
          return tool.activate();
        }
      });
    };

    Toolbox.prototype.reactToToolConfiguration = function() {
      return $('body').on('click', 'button[data-tool-parameter-value]', function(event) {
        var key, value, _base;
        value = $(this).attr('data-tool-parameter-value');
        key = $(this).parent().attr('data-tool-parameter');
        (_base = grumble.tool).parameters || (_base.parameters = {});
        return grumble.tool.parameters[key] = value;
      });
    };

    return Toolbox;

  })();

}).call(this);
