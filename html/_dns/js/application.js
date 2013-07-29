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
			    				$('<tr></tr>')
			    				.append(
			    					$('<td></td>').text(this.file),
			    					$('<td></td>').text(this.software),
			    					$('<td></td>').text(this.read ? 'Yes' : 'No'),
			    					$('<td></td>').text(this.write ? 'Yes' : 'No')
		    					));
			    		});
			    		return;
		    		}
		    		else if (data.zone && data.zone.file) {
		    			$('#dns-content table tbody')
		    			.empty()
		    			.append(
		    				$('<tr></tr>')
		    				.append(
		    					$('<td></td>').text(data.zone.file),
		    					$('<td></td>').text(data.zone.software),
		    					$('<td></td>').text(data.zone.read ? 'Yes' : 'No'),
		    					$('<td></td>').text(data.zone.write ? 'Yes' : 'No')
	    					));
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
							$('#dns-content p')
							.text('Unable to created zone file '+file+': '+window.lim.getXHRError(jqXHR))
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
	    				var file = $('#dns-content select option:selected').text();
		    			if (file) {
		    				$('#dns-content form').remove();
		    				$('#dns-content').append(
		    					$('<p></p>').append(
		    						$('<i></i>')
		    						.text('Loading zone file '+file+' ...')
	    						));
		    				window.lim.getJSON('/dns/zone', {
		    					zone: {
		    						file: file,
		    						as_content: true
		    					}
		    				})
		    				.done(function (data) {
		    					if (data.zone && !data.zone.length && data.zone.file) {
		    						$('#dns-content p').text('Content of zone file '+file);
		    						$('#dns-content').append(
		    							$('<pre class="prettyprint linenums"></pre>')
		    							.text(data.zone.content)
		    							);
		    						prettyPrint();
		    						return;
		    					}
		    					
								$('#dns-content p')
								.text('Zone file '+file+' not found');
		    				})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to read zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
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
			    				$('<option></option>').text(this.file)
			    				);
			    		});
			    		$('#dns-content select').prop('disabled',false);
			    		$('#dns-content .selectpicker').selectpicker('refresh');
			    		$('#dns-content #submit').prop('disabled',false);
			    		return;
		    		}
		    		else if (data.zone && data.zone.file) {
		    			$('#dns-content select')
		    			.empty()
		    			.append($('<option></option>').text(data.zone.file));

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
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
	    				var file = $('#dns-content select option:selected').text();
		    			if (file) {
		    				$('#dns-content form').remove();
		    				$('#dns-content').append(
		    					$('<p></p>').append(
		    						$('<i></i>')
		    						.text('Loading zone file '+file+' ...')
	    						));
		    				window.lim.getJSON('/dns/zone', {
		    					zone: {
		    						file: file,
		    						as_content: true
		    					}
		    				})
		    				.done(function (data) {
		    					if (data.zone && !data.zone.length && data.zone.file) {
		    						window.lim.loadPage('/_dns/zone_update_edit.html')
		    						.done(function (data2) {
		    							$('#dns-content').html(data2);
		    							$('#dns-content legend').text('Edit zone file '+file);
		    							$('#dns-content textarea').val(data.zone.content);
		    							$('#dns-content form').submit(function () {
		    								var content = $('#dns-content textarea').val();
		    								
		    			    				$('#dns-content form').remove();
		    			    				$('#dns-content').append(
		    			    					$('<p></p>').append(
		    			    						$('<i></i>')
		    			    						.text('Saving zone file '+file+' ...')
		    		    						));
		    			    				
		    			    				window.lim.postJSON('/dns/zone', {
		    			    					zone: {
		    			    						file: file,
		    			    						content: content
		    			    					}
		    			    				})
		    			    				.done(function (data) {
	    										$('#dns-content p')
	    										.text('Saved zone file '+file+' successfully')
	    										.addClass('text-success');
		    			    				})
	    									.fail(function (jqXHR) {
	    										$('#dns-content p')
	    										.text('Unable to save zone file '+file+': '+window.lim.getXHRError(jqXHR))
	    										.addClass('text-error');
	    									});
		    								return false;
		    							});
		    						});
		    						return;
		    					}
		    					
								$('#dns-content p')
								.text('Zone file '+file+' not found');
		    				})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to read zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
		    			return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getZoneUpdate();
				});
			},
			getZoneUpdate: function () {
				window.lim.getJSON('/dns/zones')
				.done(function (data) {
		    		if (data.zone && data.zone.length) {
		    			$('#dns-content select').empty();
		    			
			    		data.zone.sort(function (a, b) {
			    			return (a.file > b.file) ? 1 : ((a.file > b.file) ? -1 : 0);
			    		});

			    		$.each(data.zone, function () {
			    			$('#dns-content select').append(
			    				$('<option></option>').text(this.file)
			    				);
			    		});
			    		$('#dns-content select').prop('disabled',false);
			    		$('#dns-content .selectpicker').selectpicker('refresh');
			    		$('#dns-content #submit').prop('disabled',false);
			    		return;
		    		}
		    		else if (data.zone && data.zone.file) {
		    			$('#dns-content select')
		    			.empty()
		    			.append($('<option></option>').text(data.zone.file));

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
