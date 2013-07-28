(function ($) {
	$(function () {
		window.lim.module.dns = {
			init: function () {
				var that = this;
				
				$('.sidebar-nav a[href="#about"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadAbout();
	    			return false;
				});
				
				// ZONE
				
				$('.sidebar-nav a[href="#zone_list"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadZoneList();
	    			return false;
				});
				$('.sidebar-nav a[href="#zone_create"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadZoneCreate();
	    			return false;
				});
				$('.sidebar-nav a[href="#zone_read"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadZoneRead();
	    			return false;
				});
				$('.sidebar-nav a[href="#zone_update"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadZoneUpdate();
	    			return false;
				});
				$('.sidebar-nav a[href="#zone_delete"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadZoneDelete();
	    			return false;
				});

				// OPTION
				
				$('.sidebar-nav a[href="#opt_list"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadOptionList();
	    			return false;
				});
				$('.sidebar-nav a[href="#opt_create"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadOptionCreate();
	    			return false;
				});
				$('.sidebar-nav a[href="#opt_read"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadOptionRead();
	    			return false;
				});
				$('.sidebar-nav a[href="#opt_update"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadOptionUpdate();
	    			return false;
				});
				$('.sidebar-nav a[href="#opt_delete"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadOptionDelete();
	    			return false;
				});

				// RESOURCE RECORD
				
				$('.sidebar-nav a[href="#rr_list"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadRRList();
	    			return false;
				});
				$('.sidebar-nav a[href="#rr_create"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadRRCreate();
	    			return false;
				});
				$('.sidebar-nav a[href="#rr_read"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadRRRead();
	    			return false;
				});
				$('.sidebar-nav a[href="#rr_update"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadRRUpdate();
	    			return false;
				});
				$('.sidebar-nav a[href="#rr_delete"]').click(function () {
					$('.sidebar-nav li').removeClass('active');
					$(this).parent().addClass('active');
					that.loadRRDelete();
	    			return false;
				});

				this.loadAbout();
			},
			//
			loadAbout: function () {
				window.lim.loadPage('/_dns/about.html')
				.done(function (data) {
					$('#dns-content').html(data);
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			//
			// ZONE
			//
			//
			loadZoneList: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_list.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getZoneList();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getZoneList: function () {
			},
			//
			loadZoneCreate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_create.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getZoneCreate();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getZoneCreate: function () {
			},
			//
			loadZoneRead: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_read.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getZoneRead();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getZoneRead: function () {
			},
			//
			loadZoneUpdate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_update.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getZoneUpdate();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getZoneUpdate: function () {
			},
			//
			loadZoneDelete: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_delete.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getZoneDelete();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getZoneDelete: function () {
			},
			//
			// OPTION
			//
			//
			loadOptionList: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_list.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getOptionList();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getOptionList: function () {
			},
			//
			loadOptionCreate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_create.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getOptionCreate();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getOptionCreate: function () {
			},
			//
			loadOptionRead: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_read.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getOptionRead();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getOptionRead: function () {
			},
			//
			loadOptionUpdate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_update.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getOptionUpdate();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getOptionUpdate: function () {
			},
			//
			loadOptionDelete: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_delete.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getOptionDelete();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getOptionDelete: function () {
			},
			//
			// RESOURCE RECORD
			//
			//
			loadRRList: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_list.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getRRList();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getRRList: function () {
			},
			//
			loadRRCreate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_create.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getRRCreate();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getRRCreate: function () {
			},
			//
			loadRRRead: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_read.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getRRRead();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getRRRead: function () {
			},
			//
			loadRRUpdate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_update.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getRRUpdate();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getRRUpdate: function () {
			},
			//
			loadRRDelete: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_delete.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getRRDelete();
				})
				.fail(function () {
					$('#content').text('Something went very wrong ...');
				});
			},
			getRRDelete: function () {
			},
		};
		window.lim.module.dns.init();
	});
})(window.jQuery);
