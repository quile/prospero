// prospero core js
// requires jQuery

var prospero = (function() {
    var _componentRegistry = {};

    function Component( nodeId ) {
        return this.init( nodeId );
    }

    Component.prototype = {
        init: function( nodeId ) {
            this._nodeId = nodeId;
            this._children = [];
            this._childrenByNodeId = {};
            _componentRegistry[ nodeId ] = this;
            return this;
        },

        nodeId: function() { return this._nodeId },

        addChild: function( child ) {
            this._children.push( child );
            this._childrenByNodeId[ child.nodeId() ] = child;
        },

        children: function() {
            return this._children;
        },

        childWithNodeId: function( nodeId ) {
            return this._childrenByNodeId[ nodeId ];
        },
    };

    // Parent of all FormComponents
    function FormComponent( nodeId ) {
        Component.apply( this, arguments );
        return this;
    }

    jQuery.extend( FormComponent.prototype, Component.prototype, {
        init: function( nodeId ) {
            Component.prototype.init.apply( this, arguments );
            this._isRequired = false;
            this._errorMessages = {};
            this._element = jQuery( "#" + nodeId );
            return this;
        },

        value:    function()  { return this._element.val() },
        setValue: function(v) { this._element.val( v )     },
        isRequired:    function()  { return this._isRequired },
        setIsRequired: function(v) { this._isRequired = v    },

        // this will be overridden
        hasValidValues: function() {
            var self = this;
            if ( self.isRequired() && !self.value() ) {
                return false;
            }
            return true;
        },

        requiredErrorMessage: function() {
            return this.errorMessageForKey( "IS_REQUIRED" );
        },

        setRequiredErrorMessage: function( msg ) {
            this.setErrorMessageForKey( msg, "IS_REQUIRED" );
        },

        errorMessageForKey: function(key) {
            return this._errorMessages[ key ] || ( this.form && this.form.controller ? this.form.controller.errorMessageForKey( key ) :  key );
        },

        setErrorMessageForKey: function( msg, key ) {
            this._errorMessages[ key ] = msg;
        },

        displayErrorMessage: function( msg ) {
            jQuery('#' + this.nodeId() + "-error").html( msg ).show( 'normal' ).css( "error" );
        },

        displayErrorMessageForKey: function( key ) {
            this.displayErrorMessage( this.errorMessageForKey( key ) );
        },

        indicateValidationFailure: function() {
            var self = this;

            // special case that should work with most components:
            if ( self.isRequired() && !self.value() && self.requiredErrorMessage() ) {
                self.displayErrorMessage( self.requiredErrorMessage() );
            }
        }
    });

    // Subclasses for the system components.
    // Lots of them don't actually need any
    // special code.

    function TextField( nodeId ) {
        FormComponent.apply( this, arguments );
        return this;
    }
    jQuery.extend( TextField.prototype, FormComponent.prototype );

    function Text( nodeId ) {
        TextField.apply( this, arguments );
        return this;
    }
    jQuery.extend( Text.prototype, TextField.prototype );

    function HiddenField( nodeId ) {
        TextField.apply( this, arguments );
        return this;
    }
    jQuery.extend( HiddenField.prototype, TextField.prototype );

    function Password( nodeId ) {
        TextField.apply( this, arguments );
        return this;
    }
    jQuery.extend( Password.prototype, TextField.prototype );

    function PopUpMenu( nodeId ) {
        FormComponent.apply( this, arguments );
        return this;
    }
    jQuery.extend( PopUpMenu.prototype, FormComponent.prototype );


    function RadioButtonGroup( nodeId ) {
        PopUpMenu.apply( this, arguments );
        return this;
    }
    jQuery.extend( RadioButtonGroup.prototype, PopUpMenu.prototype, {
        value: function() {
            return this._element.find('input[type="radio"]').val();
        },
        setValue: function( v ) {
            this._element.find('input[type="radio"]').val( [v] );
        }
    });

    function ScrollingList( nodeId ) {
        PopUpMenu.apply( this, arguments );
        return this;
    }
    jQuery.extend( ScrollingList.prototype, PopUpMenu.prototype );

    function CheckBoxGroup( nodeId ) {
        ScrollingList.apply( this, arguments );
        return this;
    }
    jQuery.extend( CheckBoxGroup.prototype, ScrollingList.prototype, {
        value: function() {
            var values = [];
            this._element.find('input[type="checkbox"]:checked').each( function( index, cb ) {
                values.push( jQuery(cb).val() );
            });
            return values;
        },
        setValue: function(v) {
            this._element.find('input[type="checkbox"]').each( function( index, cb ) {
                var jcb = jQuery(cb);
                jcb.attr( 'checked', false );
                jQuery(v).each( function( vindex, val ) {
                    if ( val === jcb.attr('value') ) {
                        jcb.attr( 'checked', true );
                    }
                })
            });
        }
    } );

    // exports
    return {
        // export the component classes
        Component: Component,
        FormComponent: FormComponent,

        // System components
        TextField: TextField,
        Text: Text,
        HiddenField: HiddenField,
        Password: Password,
        PopUpMenu: PopUpMenu,
        RadioButtonGroup: RadioButtonGroup,
        ScrollingList: ScrollingList,
        CheckBoxGroup: CheckBoxGroup,

        // export a method to look up components in the hierarchy
        componentWithId: function( nodeId ) {
            return _componentRegistry[ nodeId ];
        }
    };
})();