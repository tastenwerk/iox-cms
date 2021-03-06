//= require jquery_ujs

//= require select2

//= require i18n
//= require i18n/translations

//= require 3rdparty/jquery.center
//= require 3rdparty/jquery-ui-1.10.3.custom
//= require 3rdparty/jquery.nested-sortable.min
//= require 3rdparty/bootstrap
//= require 3rdparty/knockout
//= require 3rdparty/moment-2.0.0.min
//= require 3rdparty/moment.lang.de
//= require 3rdparty/jquery.blockui

//= require iox/browser_detect

//= require 3rdparty/kendoui/kendo.web.min
//= require 3rdparty/kendoui/cultures/kendo.culture.de-DE.min
//= require 3rdparty/kendoui/cultures/kendo.culture.en-GB.min

//= require iox/iox.core
//= require iox/iox.flash
//= require iox/iox.tabs
//= require iox/iox.tree
//= require iox/iox.win

//= require_self

$(function(){

  $('.js-get-focus:first').focus();

  $('.iox-app-nav a').tooltip({
    placement: 'right'
  });

  $('[rel=tooltip]').tooltip({
    placement: 'right'
  });

  $.blockUI.defaults.css = {};
  $.blockUI.defaults.overlayCSS = {};
  $.blockUI.defaults.message = iox.loader;

  $('.iox-mcc').css( 'height', ( $(window).height() - $('.iox-top-nav').height() - 1 ) );
  if( $('.iox-sidebar-arrow').length && $('.iox-app-nav li.active a').length ){
    $('.iox-sidebar-arrow').css('top', $('.iox-app-nav li.active a').offset().top-40);
  }

  // data-xhr-url indicates a snippet to be loaded
  // into it's container
  $('[data-xhr-url]').each( function(e){

    $(this).block({
      message: iox.loaderHorizontal+'<span>'+($(this).attr('data-xhr-wait-txt') || '')+'</span>'
    });
    var self = this;
    $.ajax({
      url: $(this).attr('data-xhr-url'),
      dataType: 'html',
      type: 'get'
    }).done( function( htmlRes ){
      $(self).unblock();
      $(self).html( htmlRes );
    });

  });

  // data-xhr-win makes clicking an element loading it's data-xhr-href or
  // href element
  $(document).on('click', '[data-xhr-win]', function(e){
    e.preventDefault();
    var self = this;
    var url = $(this).attr('data-xhr-href') || $(this).attr('href');
    if( !url )
      throw Error('no href nor data-xhr-href found');

    var $loader = $('<div>'+iox.loaderHorizontal+'</div>')
      .find('.iox-loader-horizontal')
        .attr('title', ($(this).attr('data-xhr-wait-title') || ''));

    $(this).block({
      message: $loader.html()+'<span>'+($(this).attr('data-xhr-wait-txt') || '')+'</span>'
    });

    $.ajax({
      url: url,
      dataType: 'html',
      type: 'get'
    }).done( function( htmlRes ){
      $(self).unblock();
      var options = { content: htmlRes };
      if( $(self).attr('data-xhr-win-title') )
        options.title = $(self).attr('data-xhr-win-title');
      if( $(self).attr('data-xhr-win-callback') )
        options.completed = window[$(self).attr('data-xhr-win-callback')];
      if( $(self).attr('data-xhr-win-save-form-button') )
        options.saveFormBtn = true;
      new iox.Win( options );
    });
  });

  $('body').on('click', '.iox-simple-select-trigger', function(e){
    e.preventDefault();
    $(this).closest('.iox-simple-select').find('.iox-simple-select-list').slideToggle(100);
    $(this).closest('.iox-simple-select').toggleClass('toggled');
  });

  $(document).on('click', '[data-confirmation-win]', function(e){
    e.preventDefault();
    new iox.Win({ content: '<div class="content-padding">'+$(this).attr('data-confirmation-txt')+'</div><div class="iox-win-footer"><button class="btn" data-close-win="true">'+iox.Win.defaults.i18n.ok+'</button></div>' });
  });

  $(document).on('click', '[data-y-n-win]', function(e){
    e.preventDefault();
    options = { 
      yesNoQuestion: $(this).attr('data-y-n-txt'),
      trigger: e.target
    };
    if( $(this).attr('data-y-n-callback') )
      options.completed = window[$(this).attr('data-y-n-callback')];
    new iox.Win( options );
  });

  $('body').on('click', '[data-role=submit]', function(e){
    e.preventDefault();
    $(this).closest('.iox-content').find('form:first').submit();
  });

  $('body').on('submit', '[data-role=submitAndBack]', function(e){
    if( $(this).closest('.iox-content-padding').find('[data-role=switch2content]').length )
      $(this).closest('.iox-content-padding').find('[data-role=switch2content]').click();
  });

  $('body').on('click', '[data-role=switch2content]', function(e){
    var $prevContainer = $(this).closest('.iox-details-container').prev('.iox-content');
    $(this).closest('.iox-details-container').remove();
    if( $prevContainer.length )
      $prevContainer.show();
    else
      $('.iox-content-container').show();
  });

  $('body').on('click', '[data-role=switchBackContent]', function(e){
    iox.switchContent('prev');
  });

  $(document).on('keyup', function(e){
    if( e.keyCode === 27 && $('.iox-win').length )
      $('.iox-win:last').data('ioxWin').close();
  });


  BrowserDetect.init();
  var browserFailedMsg = 'Your Browser is too old for this system. Please update to a newer version of ' + BrowserDetect.browser + '. Currently you have version ' + BrowserDetect.version + '. You can continue using this site, but cannot guarantee everything working as expected. For more information, please contact contact@tastenwerk.com';
  if( BrowserDetect.browser == 'Firefox' && BrowserDetect.version < 21 )
    alert( browserFailedMsg );
  else if( BrowserDetect.browser == 'Chrome' && BrowserDetect.version < 25 )
    alert( browserFailedMsg );
  else if( BrowserDetect.browser == 'Explorer' && BrowserDetect.version < 10 )
    alert( browserFailedMsg );
  else if( BrowserDetect.browser == 'Safari' && BrowserDetect.version < 6 )
    alert( browserFailedMsg );

});