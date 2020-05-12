(function($) {

	"use strict";


	//Hide Loading Box (Preloader)
	function handlePreloader() {
		var preloader = $(".preloader");
		if(preloader.length){
			preloader.delay(200).fadeOut(500);
		}
	}


	//Update Header Style and Scroll to Top
	function headerStyle() {
		var mainheader = $('.main-header');
		if(mainheader.length){
			var windowpos = $(window).scrollTop();
			var siteHeader = mainheader;
			var scrollLink = $('.scroll-to-top');
			if (windowpos >= 250) {
				siteHeader.addClass('fixed-header');
				scrollLink.fadeIn(300);
			} else {
				siteHeader.removeClass('fixed-header');
				scrollLink.fadeOut(300);
			}
		}
	}

	headerStyle();

	if($('.main-menu').length){
		var navbar_collapse = $('.navbar-collapse');
		$('.navbar-toggle').on('click', function() {
		//$('.navbar-toggle').click(function() {
		   navbar_collapse.addClass( "menu-transition" );
		   navbar_collapse.fadeToggle( "18000" );
		});
	}


	//Submenu Dropdown Toggle
	if($('.main-header .navigation li.dropdown ul').length){
		$('.main-header .navigation li.dropdown').append('<div class="dropdown-btn"><span class="fa fa-angle-down"></span></div>');

		//Dropdown Button
		$('.main-header .navigation li.dropdown .dropdown-btn').on('click', function() {
			$(this).prev('ul').slideToggle(500);
		});

		//Disable dropdown parent link
		$('.navigation li.dropdown > a').on('click', function(e) {
			e.preventDefault();
		});

		//Main Menu Fade Toggle
		$('.header-style-three .nav-toggler').on('click', function() {
			$('.header-style-three .main-menu').fadeToggle(300);
		});

	}


	//Custom Seclect Box
	var custom_select_box = $('.custom-select-box');
	if(custom_select_box.length){
		custom_select_box.selectmenu().selectmenu('menuWidget').addClass('overflow');
	}


	//Event Countdown Timer
	var time_countdown = $('.time-countdown');
	if(time_countdown.length){
		time_countdown.each(function() {
		var $this = $(this), finalDate = $(this).data('countdown');
		$this.countdown(finalDate, function(event) {
			var $this = $(this).html(event.strftime('' + '<div class="counter-column"><div class="counter-inner"><span class="count">%D</span>Days</div></div> ' + '<div class="counter-column"><div class="counter-inner"><span class="count">%H</span>Hours</div></div>  ' + '<div class="counter-column"><div class="counter-inner"><span class="count">%M</span>Minitus</div></div>  ' + '<div class="counter-column"><div class="counter-inner"><span class="count">%S</span>Seconds</div></div>'));
		});
	 });
	}


	//Jquery Spinner / Quantity Spinner
	if($('.quantity-spinner').length){
		 $('.quantity-spinner .plus').on('click', function() {
			var val = $(this).prev('.prod_qty').val();
			$(this).prev('.prod_qty').val((val*1)+1);
		});
		$('.quantity-spinner .minus').on('click', function(){
			var val = $(this).next('.prod_qty').val();
			if (val != 1 ){
			$(this).next('.prod_qty').val((val*1)-1);
			}
		});
	}


	//Tabs Box
	if($('.tabs-box').length){
		$('.tabs-box .tab-buttons .tab-btn').on('click', function(e) {
			e.preventDefault();
			var target = $($(this).attr('data-tab'));

			if ($(target).is(':visible')){
				return false;
			}else{
				target.parents('.tabs-box').find('.tab-buttons').find('.tab-btn').removeClass('active-btn');
				$(this).addClass('active-btn');
				target.parents('.tabs-box').find('.tabs-content').find('.tab').fadeOut(0);
				target.parents('.tabs-box').find('.tabs-content').find('.tab').removeClass('active-tab');
				$(target).fadeIn(300);
				$(target).addClass('active-tab');
			}
		});
	}


	//Single Item Carousel
	function quote_carousel(){
		var single_item_carousel = $('.single-item-carousel');
		if (single_item_carousel.length) {
			single_item_carousel.owlCarousel({
				loop:true,
				margin:10,
				nav:true,
				smartSpeed: 1000,
				autoplay: 5000,
				navText: [ '<span class="ion-ios-arrow-thin-left"></span>', '<span class="ion-ios-arrow-thin-right"></span>' ],
				responsive:{
					0:{
						items:1
					},
					600:{
						items:1
					},
					1200:{
						items:1
					}
				}
			});
		}
	}

	//LightBox / Fancybox
	var lightbox_image = $('.lightbox-image');
	if(lightbox_image.length) {
		lightbox_image.fancybox({
			openEffect  : 'fade',
			closeEffect : 'fade',
			helpers : {
				media : {}
			}
		});
	}


	//Contact Form Validation
	var contact_form = $('#contact-form');
	if(contact_form.length){
		contact_form.validate({
			rules: {
				username: {
					required: true
				},
				email: {
					required: true
				},
				message: {
					required: true
				}
			}
		});
	}


	// Scroll to a Specific Div
	var scroll_to_target = $('.scroll-to-target');
	if(scroll_to_target.length){
		scroll_to_target.on('click', function() {
			var target = $(this).attr('data-target');
		   // animate
		   $('html, body').animate({
			   scrollTop: $(target).offset().top
			 }, 1000);
		});
	}


	// Elements Animation
	if($('.wow').length){
		var wow = new WOW(
		  {
			boxClass:     'wow',      // animated element css class (default is wow)
			animateClass: 'animated', // animation css class (default is animated)
			offset:       0,          // distance to the element when triggering the animation (default is 0)
			mobile:       false,       // trigger animations on mobile devices (default is true)
			live:         true       // act on asynchronously loaded content (default is true)
		  }
		);
		wow.init();
	}

/* ==========================================================================
   When document is Scrollig, do
   ========================================================================== */

	$(window).on('scroll', function() {
		headerStyle();
	});

/* ==========================================================================
   When document is loaded, do
   ========================================================================== */

	$(window).on('load', function() {
		handlePreloader();
		quote_carousel();
	});

})(window.jQuery);
