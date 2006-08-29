function this = testInheritance

this = inherit(TestCase()...
    ,public(...
    @testNonOverride...
    ,@testOverride...
    ,@testDelegateToParent...
    ,@testDelegateToChild...
    ,@testDelegateToParentToOverridingChild...
    ,@testOverrideDelegates...
    ,@testDelegateToGrandparent...
    ,@testDelegateToGrandchild...
    ,@testDelegateToGrandparentToGrandchild...
    ,@testParents...
    ,@testProperties...
    ,@testVersion...
    ,@testInheritObjects...
    ));

    function this = Parent
        this = public(@bar,@foo,@quux,@boffo,@yip, @gravorsh);

        function r = foo
            r = 'Parent';
        end

        function r = bar
            r = 'Parent';
        end

        function r = quux
            r = this.bar();
        end
        
        function r = boffo
            r = 'Parent';
        end
        
        function r = yip
            r = this.gravorsh();
        end
    end

    function this = Child
        this = public(@bar, @baz, @quuux, @boffo);
        [this, parent_] = inherit(Parent(), this);

        function r = bar
            r = 'Child';
        end

        function r = baz
            r = this.foo();
        end

        function r = quuux
            r = this.quux();
        end
        
        function r = boffo
            %how to delegate to a parent - the _0 suffix
            r = [parent_.boffo() ' + Child'];
        end
        
    end

    function this = Grandchild
        this = public(@gravorsh, @flurbl);
        this = inherit(Child(),this);
        
        function r = gravorsh
            r = 'Grandchild';
        end
        
        function r = flurbl
            r = this.yip();
        end
    end

    function testNonOverride
        c = Child();
        assertEquals('Parent', c.foo());
    end

    function testOverride
        c = Child;
        assertEquals('Child', c.bar());
    end

    function testDelegateToParent
        c = Child();
        assertEquals('Parent', c.baz())
    end

    function testDelegateToChild
        c = Child();
        assertEquals('Child', c.quux());
    end

    function testDelegateToParentToOverridingChild
        %Pay attention, this is a test that matlab's objects fail entirely
        c = Child();
        assertEquals('Child', c.quuux());
    end

    function testOverrideDelegates
        %when you override a method in your ancestor, the old method gets
        %renamed as methodname_0 and remains accessible to you that way.
        c = Child();
        assertEquals('Parent + Child', c.boffo());
    end

    function testDelegateToGrandparent
        g = Grandchild();
        assertEquals('Parent', g.foo());
    end

    function testDelegateToGrandchild
        g = Grandchild();
        assertEquals('Grandchild', g.gravorsh());
        
    end

    function testDelegateToGrandparentToGrandchild
        g = Grandchild();
        assertEquals('Grandchild', g.flurbl());
    end

    function testParents
        %inherited objects get a 'parent__' field that makes sure you know
        %what was inherited.
        
        obj = inherit(one, two);
        onep = obj.parents__{1};
        twop = obj.parents__{2};
        
        assertEquals(obj.bar(), 'two');
        assertEquals(onep.bar(), 'one');
        assertEquals(twop.bar(), 'two');
        
        function this = one
            this = public(@foo, @bar);
            
            function  v = foo
                v = 'one';
            end
            
            function v = bar
                v = 'one';
            end
        end
        
        function this = two
            this = public(@bar, @baz);
            
            function v = bar
                v = 'two';
            end
            
            function v = baz
                v = 'two';
            end
        end
    end

    function testProperties
        %inherited objects get a 'properties__' cell array of strings.
        
        obj = inherit(...
            properties('one', 1, 'two', 2)...
            ,properties('one', 1, 'three', 3)...
            );

        assertEquals(3, numel(obj.properties__));
        assert(strmatch('one', obj.properties__));
        assert(strmatch('two', obj.properties__));
        assert(strmatch('three', obj.properties__));
    end

    function testVersion
        %all objects get a version__ field that gives the SVN path, function
        %name, and SVN version number of the file creating the object.
        
        obj = Parent();
        vers = obj.version__;
        
        %we make sure the info I am reporting matches the auto-substituted
        %info (the 'url' and 'revision' lines below are auto-filled in by
        %SVN).
        fninfo = functions(@Parent);
        url = '$HeadURL$';
        revision = '$Revision$';
        
        %process down the url and revision here
        url = regexprep(url, '\$HeadURL: (.*) \$', '$1');
        revision = regexprep(revision, '\$Revision: (.*) \$', '$1');
        revision = str2num(revision);
        
        assertEquals(fninfo.function, vers.function);
        assertEquals(url, vers.url);
        assertEquals(revision, vers.revision);
    end

    function testInheritObjects
        %you can inherit from object wrappers - the object wrapper-ness
        %gets stripped from the outermost object. calling object() again
        %puts it back.
        fail('not written');
    end
        
end
