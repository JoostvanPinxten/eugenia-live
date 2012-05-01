
/*
  @depend tool.js
*/


(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  paper.LinkTool = (function(_super) {
    var DraftLink, DraftingLayer;

    __extends(LinkTool, _super);

    LinkTool.name = 'LinkTool';

    function LinkTool() {
      return LinkTool.__super__.constructor.apply(this, arguments);
    }

    LinkTool.prototype.parameters = {
      'strokeColor': 'black',
      'strokeStyle': 'solid'
    };

    LinkTool.prototype.draftLink = null;

    LinkTool.prototype.draftingLayer = null;

    LinkTool.prototype.drafting = false;

    LinkTool.prototype.onMouseMove = function(event) {
      var hitResult;
      hitResult = paper.project.hitTest(event.point);
      paper.project.activeLayer.selected = false;
      if (hitResult && hitResult.item.closed) {
        return hitResult.item.selected = true;
      }
    };

    LinkTool.prototype.onMouseDown = function(event) {
      var hitResult;
      hitResult = paper.project.activeLayer.hitTest(event.point);
      if (hitResult) {
        this.drafting = true;
        this.draftingLayer = new DraftingLayer(paper.project.activeLayer);
        return this.draftLink = new DraftLink(event.point);
      }
    };

    LinkTool.prototype.onMouseDrag = function(event) {
      var hitResult;
      if (this.drafting) {
        this.draftLink.extendTo(event.point);
        hitResult = this.draftingLayer.hitTest(event.point);
        if (hitResult && hitResult.item.closed) {
          paper.project.layers[0].selected = false;
          return hitResult.item.selected = true;
        }
      }
    };

    LinkTool.prototype.onMouseUp = function(event) {
      var attributes, hitResult, l, link, s;
      if (this.drafting) {
        hitResult = this.draftingLayer.hitTest(event.point);
        if (hitResult && hitResult.item.closed) {
          attributes = this.parameters;
          link = this.draftLink.finalise();
          attributes.source_id = this.draftingLayer.hitTest(link.firstSegment.point).item.spine_id;
          attributes.target_id = this.draftingLayer.hitTest(link.lastSegment.point).item.spine_id;
          this.draftingLayer.dispose();
          attributes.segments = (function() {
            var _i, _len, _ref, _results;
            _ref = link.segments;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              s = _ref[_i];
              _results.push({
                point: {
                  x: s.point.x,
                  y: s.point.y
                },
                handleIn: {
                  x: s.handleIn.x,
                  y: s.handleIn.y
                },
                handleOut: {
                  x: s.handleOut.x,
                  y: s.handleOut.y
                }
              });
            }
            return _results;
          })();
          console.log("creating link");
          l = new grumble.Link(attributes);
          console.log("created: " + l);
          l.save();
          console.log("saved");
        }
        this.draftingLayer.dispose();
        paper.project.activeLayer.selected = false;
        return this.drafting = false;
      }
    };

    DraftingLayer = (function() {

      DraftingLayer.name = 'DraftingLayer';

      DraftingLayer.prototype.parent = null;

      DraftingLayer.prototype.layer = null;

      function DraftingLayer(parent) {
        this.parent = parent;
        this.layer = new paper.Layer();
      }

      DraftingLayer.prototype.hitTest = function(point) {
        return this.parent.hitTest(point);
      };

      DraftingLayer.prototype.dispose = function() {
        this.layer.remove();
        return this.parent.activate();
      };

      return DraftingLayer;

    })();

    DraftLink = (function() {

      DraftLink.name = 'DraftLink';

      DraftLink.prototype.path = null;

      function DraftLink(origin) {
        this.path = new paper.Path([origin]);
        this.path.strokeColor = 'black';
        this.path.dashArray = [10, 4];
      }

      DraftLink.prototype.extendTo = function(point) {
        return this.path.add(point);
      };

      DraftLink.prototype.finalise = function() {
        this.path.simplify(100);
        return this.path;
      };

      return DraftLink;

    })();

    return LinkTool;

  })(grumble.Tool);

}).call(this);