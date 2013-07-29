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
				});
			},
			getZoneList: function () {
				window.lim.getJSON('/dns/zones')
				.done(function (data) {
		    		if (data.zone && data.zone.length) {
		    			$('#dns-content table tbody').empty();
		    			
			    		data.zone.sort(function (a, b) {
			    			return (a.file > b.file) ? 1 : ((a.file > b.file) ? -1 : 0);
			    		});

			    		$.each(data.zone, function () {
			    			$('#dns-content table tbody').append(
			    				'<tr>'+
			    				'<td>'+this.file+'</td>'+
			    				'<td>'+this.software+'</td>'+
			    				'<td>'+(this.read ? 'Yes' : 'No')+'</td>'+
			    				'<td>'+(this.write ? 'Yes' : 'No')+'</td>'+
			    				'</tr>'
			    				);
			    		});
			    		return;
		    		}
		    		else if (data.zone.file) {
		    			$('#dns-content table tbody')
		    			.empty()
		    			.append(
		    				'<tr>'+
		    				'<td>'+data.zone.file+'</td>'+
		    				'<td>'+data.zone.software+'</td>'+
		    				'<td>'+(data.zone.read ? 'Yes' : 'No')+'</td>'+
		    				'<td>'+(data.zone.write ? 'Yes' : 'No')+'</td>'+
		    				'</tr>'
		    				);
		    			return;
		    		}
		    		
		    		$('#dns-content table td i').text('No zone files found');
				})
				.fail(function () {
					$('#dns-content table td i').text('failed');
				});
			},
			//
			loadZoneCreate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_create.html')
				.done(function (data) {
					$('#dns-content').html(data);
					$('#dns-content form').submit(function () {
						var file = $('#dns-content #file').val();
						
						$('#dns-content form').remove();
						$('#dns-content')
						.append($('<p></p>')
							.append($('<i></i>')
								.text('Creating zone file '+file+', please wait ...')
								));

						window.lim.putJSON('/dns/zone', {
							zone: {
								file: file
							}
						})
						.done(function (data) {
							$('#dns-content p')
							.text('Successfully created zone file '+file+'.')
							.addClass('text-success');
						})
						.fail(function (jqXHR) {
							var message;
							try {
								message = $.parseJSON(jqXHR.responseText)['Lim::Error'].message+'!';
							}
							catch (dummy) {
							}
							if (!message) {
								message = 'Reason unknown, please check your system logs!';
							}
							$('#dns-content p')
							.text('Unable to created zone file '+file+': '+message)
							.addClass('text-error');
						});

						return false;
					})
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
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
		    		that.getZoneRead();
				});
			},
			getZoneRead: function () {
				window.lim.getJSON('/dns/zones')
				.done(function (data) {
		    		if (data.zone && data.zone.length) {
		    			$('#dns-content select').empty();
		    			
			    		data.zone.sort(function (a, b) {
			    			return (a.file > b.file) ? 1 : ((a.file > b.file) ? -1 : 0);
			    		});

			    		$.each(data.zone, function () {
			    			$('#dns-content select').append(
			    				'<option>'+this.file+'</option>'
			    				);
			    		});
			    		$('#dns-content select').prop('disabled',false);
			    		$('#dns-content .selectpicker').selectpicker('refresh');
			    		$('#dns-content #submit').prop('disabled',false);
			    		return;
		    		}
		    		else if (data.zone.file) {
		    			$('#dns-content select')
		    			.empty()
		    			.append(
		    				'<option>'+data.zone.file+'</option>'
		    				);
			    		$('#dns-content select').prop('disabled',false);
			    		$('#dns-content .selectpicker').selectpicker('refresh');
			    		$('#dns-content #submit').prop('disabled',false);
		    			return;
		    		}
		    		
		    		$('#dns-content option').text('No zone files found');
				})
				.fail(function () {
					$('#dns-content option').text('failed');
				});
			},
			//
			loadZoneUpdate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_update.html')
				.done(function (data) {
					$('#dns-content').html(data);
					that.getZoneUpdate();
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
				});
			},
			getRRDelete: function () {
			},
		};
		window.lim.module.dns.init();
	});
})(window.jQuery);
