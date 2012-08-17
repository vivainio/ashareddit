root = window 


window.log = ->
    console.log Array::slice.call arguments if @console
    return

window.logj = (prefix, arg) ->
    log "Obj2: " + prefix        
    log JSON.stringify arg
    #log JSON.stringify arg
    

class App
    start: ->        
        #$("div[data-role=page]").page()

        log "Starting app at "
        log Date()
        @topicGroups = new RTopicGroupList
        
        #@topicGroups.fetch()
        
        #if not @topicGroups.length
        #    _.delay (=>                              
        #        $.mobile.changePage "#pagesetupwizard", 500
	#    )
              
        log 21  
        createDefaultGroups = () =>        
            @tgview.addTg "Casual",["frontpage", "pics", "fffffffuuuuuuuuuuuu", "funny", "AdviceAnimals"]
            @tgview.addTg "Code",["programming", "webdev", "javascript", "web_design", "html5", "coffeescript", "python"]

	
        $("#btnWizardCreate").on "click", => createDefaultGroups()
	


        $("#pagepreview").on "click", =>
            $.mobile.changePage "#pagemain"
            $("#previewIframe").attr "src", ""
            
        @shownCategories = new RCatList
        
        log 38
        root.redditengine = reng = new RedditEngine()

        @tgview = tg = new RTopicGroupView
        #tg.addTg "Funny stuff", ["pics", "fffffffuuuuuuuuuuuu"]
        #tg.addTg "Programming", ["javascript", "html5", "coffeescript"]
        
        #@topicGroups.sync()

        @mainview = mv = new RCatListView

        @vManageGroups = mg = new VManageGroups
        mg.render()

        @vGroupEditor = ge = new VGroupEditor
        
        log 53
        EventDispatcher.bind "selectCategories", (ev, cats) =>
            log "setting categories", cats
            mv.setCategories (cats)
            mv.render()
            reng.fetchAll()

        reng.initialize()
        createDefaultGroups()	

        @tgview.render()

        reng.fetchAll()
        log "Started up"


EventDispatcher = $({})

app = new App()

root.redditapp = app


collectionToJson = (coll)->    
    coll.map (m) ->
        o = m.toJSON()
        o.cid = m.cid
        o
    
    
class RLink extends Backbone.Model
    defaults:
        linkdesc: "no description"

class RCat extends Backbone.Model
    defaults:
        name: "funny"


class RTopicGroup extends Backbone.Model
    defaults:
        groupName: "mygroup"
        topics: ["pics", "funny"]

class RTopicGroupList extends Backbone.Collection
    #localStorage: new Store("topicgroups")
    model: RTopicGroup
    
class RTopicGroupView extends Backbone.View
    el: "#topic-group-area"
    
    initialize: ->
        pat = $("#topic-group-template").html()
        log "Using template",pat
        @template = Handlebars.compile pat        
        @tglist = app.topicGroups
        @tglist.bind "change remove", (args...) =>            
            @render()
            
        
        
        
    bindEvents: ->
        # needed because navarro doesn't support jq event delegation...
        $(".tg-name").on "click", (ev)=>
            @doSelectGroup(ev)
            
        $(".tg-topic").on "click", (ev)=>
            @doSelectTopic(ev)

    render: ->
        @$el.empty()
        
        @tglist.each (m) =>
            log "obj for rend", m.toJSON()            
            
            rend = @template
                tgname: m.get "groupName"
                topics: m.get "topics"
                tgid: m.cid
                
            
            @$el.append rend
            log "Rendered",rend
            
        @bindEvents()
                    
    addTg: (name, topics) ->
        
        #@tglist.create groupName: name, topics: topics
        m = new RTopicGroup groupName: name, topics: topics
        @tglist.add m
        #m = new Backbone.Model 
        #@tglist.add m

    makeCurrent: (elem) ->
        $(".tg-current-choice").removeClass "tg-current-choice"
        elem.addClass "tg-current-choice"
        
    doSelectGroup: (ev) ->        
        trg = $(ev.target)
        cid = trg.data("cid")
        @makeCurrent trg
        m = @tglist.getByCid cid
        
        
        EventDispatcher.trigger "selectCategories", [m.get "topics"]
        
    
    doSelectTopic: (ev) ->
        log "Topic selected"
        trg = $(ev.target)
        @makeCurrent trg
        topic = trg.text()        
        EventDispatcher.trigger "selectCategories", [[topic]]
        

    events: 
        "click .tg-name" : "doSelectGroup"
        "click .tg-topic" : "doSelectTopic"
    

class RLinkList extends Backbone.Collection
    model: RLink
    
class RCatList extends Backbone.Collection
    model: RCat
    
class RCatListView extends Backbone.View

    el: "#catlist-area"
    
    initialize:  ->
        log 192
        _.bindAll @        
        @categories_coll = new RCatList
        pat = $("#catlist-template").html()
        @catlisttmpl = Handlebars.compile pat
        @singlecatviews = {}
            
        
    render: ->
        log 201
        #@$el.empty()
        log @$el
        log 204
        #all = $('<div class="gen-cat-list-container">')
        log app.shownCategories
        log 206
        tolist =
            categories: app.shownCategories.toJSON()
            
        log 210        
        logj "tolist is",tolist.categories
        rend = @catlisttmpl tolist
        log "tolist", tolist,rend
        @$el.html rend
        
        links = @.$(".catlist-links")
        log 220
        links.each ->
            log 221
            elem = $(this)
            name = elem.data "catname"
            log name
            nv = new RCatView el: elem
            log nv
            @singlecatviews[name] = nv
            log 226
        
            
            
        
        log 215    
        """
        app.shownCategories.each (m) =>
            log 208
            name = m.get "name"
            log name
            rendered = @catlisttmpl
                catname: name
             
            log rendered
            appended = $(rendered).appendTo(all)
            
            r = appended.find(".catlist-links")
            
            #if name in @singlecatviews
            #    @singlecatviews[name].el = r
            #else
            nv = new RCatView el: r
            @singlecatviews[name] = nv
            
            
        
        log 224
        
        @$el.append(all)
        """
        
    
    setCategories: (cats)->
        log 224
        app.shownCategories.reset ({name} for name in cats)
        log 226
    
    getView: (name) -> @singlecatviews[name]
        
    categories: -> @categories_coll
        
    
    
class RCatView extends Backbone.View
    
    events:
        "click .linkcontainer"  : "doSelect"
        "click .rightedge" : "doSelectComments"
        
    modelByCid: (cid) -> @coll.getByCid cid
        
        
    openWindow: (url) ->
        #fr = $("#previewIframe")
        #fr.attr "src", url
        #$.mobile.changePage "#pagepreview"

        #mwl.loadUrl url
        console.log "Open url",url        
        window.open url
        
    doSelect: (ev) ->
        
        cid = $(ev.currentTarget).data("cid")
        #console.log ev, cid
        m = @modelByCid cid
        #console.log m
        url = m.get "url"
        @openWindow url
        
    
    doSelectComments: (ev) ->
        cid = $(ev.currentTarget).closest(".linkcontainer").data("cid")
        
        m = @modelByCid cid
        plink = m.get "permalink"        
        
        fullurl = "http://reddit.com" + plink+".compact"
        ev.stopPropagation()
        @openWindow fullurl
        
        
        
        
    initialize: ->
        log 315
        @coll = new RLinkList
        _.bindAll @
        pat = $("#link-template").html()
        @linktmpl = Handlebars.compile pat
        log 320
        
        
    renderOne: (m) ->
        thumb = m.get "thumbnail"
        #console.log thumb
        if thumb in ["default", "self"]
            #console.log "squash because",thumb
            thumb = ""
            
        sc = m.get "score"
        if sc >=0
            score = "+" + sc
        else
            score = "-" + sc

        plink = m.get "permalink"        
        
        commentsurl = "http://reddit.com" + plink+".compact"

        
        expanded = @linktmpl
        
            linkdesc: m.get "title"
            linkscore: score
            linkimg: thumb            
            linkcomments: m.get "num_comments"
            commentsurl: commentsurl
            url: m.get "url"
            cid: m.cid
            
        expanded
    
    render: ->
        log 353
        log "Nothing here yet, rewrite to use handlebars"
        
        
        #all = $('<ul data-role="listview" data-theme="c">')
        #@coll.each (m) =>
        #    all.append $(@renderOne(m))
                
        
        #@$el.empty()
        #@$el.append all
        #@$el.trigger "create"
        #all.listview()
        #all.listview("refresh")

    mkModel: (d) ->
        m = new RLink
        m.set d
        #console.log m
        m
        
    addLink: (d) ->
        m = @mkModel d
        @coll.add m

class VManageGroups extends Backbone.View
    el: "#manage-groups-area"
    
    events:
        "click .topic-group-item" : "doSelectGroup"
        "click #btnNewGroup" : "doNewGroup"
        
    initialize: ->
        _.bindAll @
        pat = $("#manage-groups-template").text()
        @tmplManageGroups = Handlebars.compile pat
        app.topicGroups.bind "change remove", =>
            @render()
            
            
    
        
        #console.log "init!",pat
        

    render: ->        
        context = { groups: collectionToJson app.topicGroups }        
        h = @tmplManageGroups context
        @$el.html h
        #@.$(".rootlist").listview()
        @$el.trigger "create"
        
        
    modelByCid: (cid) -> app.topicGroups.getByCid cid
        
    doSelectGroup: (ev) ->        
        m = @modelByCid $(ev.currentTarget).data("cid")

        @switchToGroupEditor m         
    
    switchToGroupEditor: (m) ->
        app.vGroupEditor.setModel m
        #app.vGroupEditor.render()

        $.mobile.changePage "#pagegroupeditor"
        
        #_.defer =>        
        #    $.mobile.changePage "#pagegroupeditor"
        #    app.vGroupEditor.updateList()
        
        
    doNewGroup: (ev) ->        
        m = app.topicGroups.create groupName: "<untitled>", topics: []
        #app.tgview.render()
        #app.vManageGroups.render()
        @switchToGroupEditor m
        app.vGroupEditor.setModel m
        
        
class VGroupEditor extends Backbone.View
    el: "#group-editor-area"
    
    events:
        "click #btnAdd": "doAddCat"
        "click .aRemoveCat": "doRemoveCat"
        "click #btnApplyChangeGroupName" : "doChangeGroupName"
        "keyup #inpGroupName" : "doCheckGroupName"
        
    initialize: ->
        _.bindAll @
        pat = $("#group-editor-template").text()
        @tmpl = Handlebars.compile pat
    
        $("#btnDeleteGroup").on "click", =>            
            #app.topicGroups.remove @model
            @model.destroy()
            history.back()
            
    
        
        
        #$("#pagegroupeditor").on "pagebeforecreate", =>
        #    @render()
        
    doCheckGroupName: ->        
        b = $("#btnApplyChangeGroupName")
        t = $("#inpGroupName").val()
        kl = 'ui-disabled'
        ref = false
        if t != @model.get "groupName"
            if b.hasClass kl                
                b.removeClass "ui-disabled"
                ref = true
                
        else
            if not b.hasClass kl
                b.addClass "ui-disabled"                
                ref = true
                
            
        
    updateList: ->
        ul = @.$(".rootlist")        
        ul.listview()
        ul.listview("refresh")
        
    render: ->        
        if not @model
            return
            
        context = @model.toJSON()
        h = @tmpl context
        @$el.html h
        @$el.trigger "create"
        #@updateList()
        
    setModel: (m)->
        @model = m
        @render()
        m.on "change", =>
            @render()
        @doCheckGroupName()
        
    doAddCat: (ev) ->
        
        t = $("#inpNewCategory").val()        
        if t.length < 1
            return
        m = @model
        topics = m.get "topics"                
        #topics.push t
        m.set "topics", topics.concat [t]         
        #m.save()
        
        #@render()
        #@updateList()
        
    doRemoveCat: (ev) ->
        elem =  $(ev.currentTarget)
        toRemove = elem.text()        
        ul = @.$(".rootlist")
        m = @model
        topics = _.without m.get("topics"), toRemove
        m.set "topics", topics        
        #m.save()
        
        #@render()
        #@updateList()
        
    doChangeGroupName: (ev) ->
        t = $("#inpGroupName").val()        
        @model.set "groupName", t
        #@model.save()
        @doCheckGroupName()
        
        
        
class RedditEngine    
    initialize: ->        
        #@linktmpl = _.template pat
        #console.log "template", @linktmpl
        @cats = []
        @linkviews = {}
        #@mkView "pics"
        #@mkView "funny"
        
        
        
        
        #mv.setCategories ["pics", "javascript"]
        #@mainview.addCategory("pics")
        #@mainview.addCategory("funny")
        #@mainview.render()

        
        
    fetchAll: ->
        log 506
        
        app.shownCategories.each (m) => @fetchLinks m.get "name",""
            
    fetchLinks: (cat, qargs) ->
        log 511
        qargs = "jsonp=?&"
                
        if cat == "frontpage"
            catfrag = ""
        else
            catfrag = "/r/#{cat}/"
            
        url = "http://www.reddit.com#{catfrag}/.json?#{qargs} "

        log url
        
        lv = app.mainview.getView(cat)
        $.ajax
            url: url
            jsonp: "jsonp"
            dataType: "jsonp"
            success: (resp) =>
                items = resp.data.children
                #all = $("<div>")
                for it in items
                    d = it.data
                    #console.log d
                    
                    lv.addLink d
                    #all.append(expanded)
                    
                #console.log items
                lv.render()
                

root.RedditEngine = RedditEngine    
    
reng = null
    
$ ->
    log "starting up"    
    log "...still..."
    app.start()
    log "post start up"
    
