// prospero core js

var prospero = (function() {
    function Component( var nodeId ) {
        this._nodeId = nodeId;
        this._children = [];
        this._childrenByNodeId = {};
        return this;
    }

    var _componentRegistry = {};

    Component.prototype = {
        nodeId:   function() { return this._nodeId },

        addChild: function( child ) {
            this._children.push( child );
            this._childrenByNodeId[ child.nodeId() ] = child;
            this._componentRegistry[ child.nodeId() ] = child;
        },

        children: function() {
            return this._children;
        },

        childWithNodeId: function( nodeId ) {
            return this._childrenByNodeId[ nodeId ];
        },
    };

    return {
        // export the component class
        Component: Component,

        // export a method to look up components in the hierarchy
        componentWithId: function( nodeId ) {
            return _componentRegistry[ nodeId ];
        }
    };
})();