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
			_getZoneListSelect: function () {
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
				.fail(function (jqXHR) {
					$('#dns-content')
					.empty()
					.append(
						$('<p class="text-error"></p>')
						.text('Unable to read zone list: '+window.lim.getXHRError(jqXHR))
						);
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
				.fail(function (jqXHR) {
					$('#dns-content')
					.empty()
					.append(
						$('<p class="text-error"></p>')
						.text('Unable to read zone list: '+window.lim.getXHRError(jqXHR))
						);
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
						
						if (file) {
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
								.text('Unable to create zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
						}

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
				this._getZoneListSelect();
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
		    							$('#dns-content #zoneFile').text(file);
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
				this._getZoneListSelect();
			},
			//
			loadZoneDelete: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/zone_delete.html')
				.done(function (data) {
					var file;
					
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
	    				file = $('#dns-content select option:selected').text();
	    				$('#dns-content #zoneFile').text(file);
	    				$('#deleteZoneFile').modal('show');
	    				return false;
		    		});
		    		$('#deleteZoneFile button.btn-primary').click(function () {
	    				$('#dns-content form').remove();
	    				$('#dns-content').append(
	    					$('<p></p>').append(
	    						$('<i></i>')
	    						.text('Deleting zone file '+file+' ...')
    						));
		    			$('#deleteZoneFile').modal('hide');
	    				window.lim.delJSON('/dns/zone', {
	    					zone: {
	    						file: file
	    					}
	    				})
	    				.done(function (data) {
							$('#dns-content p')
							.text('Deleted zone file '+file+' successfully')
							.addClass('text-success');
	    				})
						.fail(function (jqXHR) {
							$('#dns-content p')
							.text('Unable to read zone file '+file+': '+window.lim.getXHRError(jqXHR))
							.addClass('text-error');
						});
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getZoneDelete();
				});
			},
			getZoneDelete: function () {
				this._getZoneListSelect();
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
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text();
		    			if (file) {
		    				$('#dns-content form').remove();
		    				$('#dns-content').append(
		    					$('<p></p>').append(
		    						$('<i></i>')
		    						.text('Loading zone file '+file+' options ...')
	    						));
		    				window.lim.getJSON('/dns/zone_option', {
		    					zone: {
		    						file: file
		    					}
		    				})
		    				.done(function (data) {
		    					if (data.zone && !data.zone.length && data.zone.file) {
		    						window.lim.loadPage('/_dns/opt_list_table.html')
		    						.done(function (data2) {
		    							$('#dns-content').html(data2);
		    							$('#dns-content #zoneFile').text(file);

		    				    		if (data.zone.option && data.zone.option.length) {
		    				    			$('#dns-content table tbody').empty();
		    				    			
		    					    		data.zone.option.sort(function (a, b) {
		    					    			return (a.file > b.file) ? 1 : ((a.file > b.file) ? -1 : 0);
		    					    		});

		    					    		$.each(data.zone.option, function () {
		    					    			$('#dns-content table tbody').append(
		    					    				$('<tr></tr>')
		    					    				.append(
		    					    					$('<td></td>').text(this.name),
		    					    					$('<td></td>').text(this.value)
		    				    					));
		    					    		});
		    					    		return;
		    				    		}
		    				    		else if (data.zone.option && data.zone.option.name) {
		    				    			$('#dns-content table tbody')
		    				    			.empty()
		    				    			.append(
		    				    				$('<tr></tr>')
		    				    				.append(
		    				    					$('<td></td>').text(data.zone.option.name),
		    				    					$('<td></td>').text(data.zone.option.value)
		    			    					));
		    				    			return;
		    				    		}
		    				    		
		    				    		$('#dns-content table td i').text('No zone options found');
		    						});
		    						return;
		    					}
		    					
								$('#dns-content p')
								.text('No zone options found in zone file '+file+'.');
		    				})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to read options from zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getOptionList();
				});
			},
			getOptionList: function () {
				this._getZoneListSelect();
			},
			//
			loadOptionCreate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_create.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text(),
		    				name = $('#optionName').val(),
		    				value = $('#optionValue').val();
		    			
		    			if (file && name && value) {
							$('#dns-content form').remove();
							$('#dns-content')
							.append($('<p></p>')
								.append($('<i></i>')
									.text('Creating zone option '+name+' in zone file '+file+', please wait ...')
									));
		
							window.lim.putJSON('/dns/zone_option', {
								zone: {
									file: file,
									option: {
										name: name,
										value: value
									}
								}
							})
							.done(function (data) {
								$('#dns-content p')
								.text('Successfully created zone option '+name+' in zone file '+file+'.')
								.addClass('text-success');
							})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to create zone option '+name+' in zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
		    			
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getOptionCreate();
				});
			},
			getOptionCreate: function () {
				this._getZoneListSelect();
			},
			//
			loadOptionRead: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_read.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text(),
		    				name = $('#optionName').val();
    			
		    			if (file && name) {
							$('#dns-content form').remove();
							$('#dns-content')
							.append($('<p></p>')
								.append($('<i></i>')
									.text('Loading zone option '+name+' from zone file '+file+', please wait ...')
									));
		
							window.lim.getJSON('/dns/zone_option', {
								zone: {
									file: file,
									option: {
										name: name
									}
								}
							})
							.done(function (data) {
								if (data.zone && data.zone.file && data.zone.option && data.zone.option.name) {
		    						window.lim.loadPage('/_dns/opt_read_opt.html')
		    						.done(function (data2) {
		    							$('#dns-content').html(data2);
		    							$('#dns-content #zoneFile').text(file);
		    							$('#dns-content #optName').text(data.zone.option.name);
		    							$('#dns-content #optValue').text(data.zone.option.value);
		    						});
		    						return;
								}
								
								$('#dns-content p')
								.text('Zone option '+name+' not found in zone file '+file+'.');
							})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to load zone option '+name+' from zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
		    			
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getOptionRead();
				});
			},
			getOptionRead: function () {
				this._getZoneListSelect();
			},
			//
			loadOptionUpdate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/opt_update.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text(),
		    				name = $('#optionName').val(),
		    				value = $('#optionValue').val();
	    			
		    			if (file && name && value) {
							$('#dns-content form').remove();
							$('#dns-content')
							.append($('<p></p>')
								.append($('<i></i>')
									.text('Updating zone option '+name+' in zone file '+file+', please wait ...')
									));
		
							window.lim.postJSON('/dns/zone_option', {
								zone: {
									file: file,
									option: {
										name: name,
										value: value
									}
								}
							})
							.done(function (data) {
								$('#dns-content p')
								.text('Successfully updated zone option '+name+' in zone file '+file+'.')
								.addClass('text-success');
							})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to update zone option '+name+' in zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
		    			
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getOptionUpdate();
				});
			},
			getOptionUpdate: function () {
				this._getZoneListSelect();
			},
			//
			loadOptionDelete: function () {
				var that = this,
					file, name;
				
				window.lim.loadPage('/_dns/opt_delete.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
			    		file = $('#dns-content select option:selected').text();
	    				name = $('#optionName').val();
	    				$('#dns-content #zoneFile').text(file);
	    				$('#dns-content #optName').text(name);
	    				$('#deleteZoneOption').modal('show');
	    				return false;
		    		});
		    		$('#deleteZoneOption button.btn-primary').click(function () {
						$('#dns-content form').remove();
						$('#dns-content')
						.append($('<p></p>')
							.append($('<i></i>')
								.text('Deleting zone option '+name+' from zone file '+file+', please wait ...')
								));
		    			$('#deleteZoneOption').modal('hide');
	
						window.lim.delJSON('/dns/zone_option', {
							zone: {
								file: file,
								option: {
									name: name
								}
							}
						})
						.done(function (data) {
							$('#dns-content p')
							.text('Successfully deleted zone option '+name+' from zone file '+file+'.')
							.addClass('text-success');
						})
						.fail(function (jqXHR) {
							$('#dns-content p')
							.text('Unable to delete zone option '+name+' from zone file '+file+': '+window.lim.getXHRError(jqXHR))
							.addClass('text-error');
						});
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getOptionDelete();
				});
			},
			getOptionDelete: function () {
				this._getZoneListSelect();
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
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text();
		    			if (file) {
		    				$('#dns-content form').remove();
		    				$('#dns-content').append(
		    					$('<p></p>').append(
		    						$('<i></i>')
		    						.text('Loading zone file '+file+' resource records ...')
	    						));
		    				window.lim.getJSON('/dns/zone_rr', {
		    					zone: {
		    						file: file
		    					}
		    				})
		    				.done(function (data) {
		    					if (data.zone && !data.zone.length && data.zone.file) {
		    						window.lim.loadPage('/_dns/rr_list_table.html')
		    						.done(function (data2) {
		    							$('#dns-content').html(data2);
		    							$('#dns-content #zoneFile').text(file);

		    				    		if (data.zone.rr && data.zone.rr.length) {
		    				    			$('#dns-content table tbody').empty();
		    				    			
		    					    		$.each(data.zone.rr, function () {
		    					    			$('#dns-content table tbody').append(
		    					    				$('<tr></tr>')
		    					    				.append(
		    					    					$('<td></td>').text(this.name),
		    					    					$('<td></td>').text(this.ttl ? this.ttl : ''),
		    					    					$('<td></td>').text(this.type),
		    					    					$('<td></td>').text(this.class ? this.class : ''),
		    					    					$('<td></td>').text(this.rdata)
		    				    					));
		    					    		});
		    					    		return;
		    				    		}
		    				    		else if (data.zone.rr && data.zone.rr.name) {
		    				    			$('#dns-content table tbody')
		    				    			.empty()
		    				    			.append(
		    				    				$('<tr></tr>')
		    				    				.append(
		    				    					$('<td></td>').text(data.zone.rr.name),
		    				    					$('<td></td>').text(data.zone.rr.ttl ? data.zone.rr.ttl : ''),
		    				    					$('<td></td>').text(data.zone.rr.type),
		    				    					$('<td></td>').text(data.zone.rr.class ? data.zone.rr.class : ''),
		    				    					$('<td></td>').text(data.zone.rr.rdata)
		    			    					));
		    				    			return;
		    				    		}
		    				    		
		    				    		$('#dns-content table td i').text('No zone resource records found');
		    						});
		    						return;
		    					}
		    					
								$('#dns-content p')
								.text('No zone resource records found in zone file '+file+'.');
		    				})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to read resource records from zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getRRList();
				});
			},
			getRRList: function () {
				this._getZoneListSelect();
			},
			//
			loadRRCreate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_create.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text(),
		    				name = $('#rrName').val(),
		    				ttl = $('#rrTTL').val(),
		    				type = $('#rrType').val(),
		    				_class = $('#rrClass').val(),
		    				rdata = $('#rrRDATA').val();
		    			
		    			if (file && name && rdata) {
							$('#dns-content form').remove();
							$('#dns-content')
							.append($('<p></p>')
								.append($('<i></i>')
									.text('Creating zone resource record '+name+' in zone file '+file+', please wait ...')
									));
		
							var rr = {
								name: name,
								type: type,
								rdata: rdata
							};
							if (ttl) {
								rr.ttl = ttl;
							}
							if (_class) {
								rr.class = _class;
							}
							
							window.lim.putJSON('/dns/zone_rr', {
								zone: {
									file: file,
									rr: rr
								}
							})
							.done(function (data) {
								$('#dns-content p')
								.text('Successfully created zone resource record '+name+' in zone file '+file+'.')
								.addClass('text-success');
							})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to created zone resource record '+name+' in zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
		    			
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getRRCreate();
				});
			},
			getRRCreate: function () {
				this._getZoneListSelect();
			},
			//
			loadRRRead: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_read.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text(),
		    				name = $('#rrName').val();
    			
		    			if (file && name) {
							$('#dns-content form').remove();
							$('#dns-content')
							.append($('<p></p>')
								.append($('<i></i>')
									.text('Loading zone resource record '+name+' from zone file '+file+', please wait ...')
									));
		
							window.lim.getJSON('/dns/zone_rr', {
								zone: {
									file: file,
									rr: {
										name: name
									}
								}
							})
							.done(function (data) {
								if (data.zone && data.zone.file && data.zone.rr) {
		    						window.lim.loadPage('/_dns/rr_read_rr.html')
		    						.done(function (data2) {
		    							$('#dns-content').html(data2);
		    							$('#dns-content #zoneFile').text(file);
		    							$('#dns-content #rrName').text(name);
		    							
		    				    		if (data.zone.rr.length) {
		    				    			$('#dns-content table tbody').empty();
		    				    			
		    					    		$.each(data.zone.rr, function () {
		    					    			$('#dns-content table tbody').append(
		    					    				$('<tr></tr>')
		    					    				.append(
		    					    					$('<td></td>').text(this.name),
		    					    					$('<td></td>').text(this.ttl ? this.ttl : ''),
		    					    					$('<td></td>').text(this.type),
		    					    					$('<td></td>').text(this.class ? this.class : ''),
		    					    					$('<td></td>').text(this.rdata)
		    				    					));
		    					    		});
		    				    		}
		    				    		else if (data.zone.rr.name) {
		    				    			$('#dns-content table tbody')
		    				    			.empty()
		    				    			.append(
		    				    				$('<tr></tr>')
		    				    				.append(
		    				    					$('<td></td>').text(data.zone.rr.name),
		    				    					$('<td></td>').text(data.zone.rr.ttl ? data.zone.rr.ttl : ''),
		    				    					$('<td></td>').text(data.zone.rr.type),
		    				    					$('<td></td>').text(data.zone.rr.class ? data.zone.rr.class : ''),
		    				    					$('<td></td>').text(data.zone.rr.rdata)
		    			    					));
		    				    		}
		    						});
		    						return;
								}
								
								$('#dns-content p')
								.text('Zone resource record '+name+' not found in zone file '+file+'.');
							})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to load zone resource record '+name+' from zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
		    			
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getRRRead();
				});
			},
			getRRRead: function () {
				this._getZoneListSelect();
			},
			//
			loadRRUpdate: function () {
				var that = this;
				
				window.lim.loadPage('/_dns/rr_update.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
		    			var file = $('#dns-content select option:selected').text(),
		    				name = $('#rrName').val(),
		    				ttl = $('#rrTTL').val(),
		    				type = $('#rrType').val(),
		    				_class = $('#rrClass').val(),
		    				rdata = $('#rrRDATA').val();
		    			
		    			if (file && name && rdata) {
							$('#dns-content form').remove();
							$('#dns-content')
							.append($('<p></p>')
								.append($('<i></i>')
									.text('Updating zone resource record '+name+' in zone file '+file+', please wait ...')
									));
		
							var rr = {
								name: name,
								type: type,
								rdata: rdata
							};
							if (ttl) {
								rr.ttl = ttl;
							}
							if (_class) {
								rr.class = _class;
							}
							
							window.lim.postJSON('/dns/zone_rr', {
								zone: {
									file: file,
									rr: rr
								}
							})
							.done(function (data) {
								$('#dns-content p')
								.text('Successfully updated zone resource record '+name+' in zone file '+file+'.')
								.addClass('text-success');
							})
							.fail(function (jqXHR) {
								$('#dns-content p')
								.text('Unable to update zone resource record '+name+' in zone file '+file+': '+window.lim.getXHRError(jqXHR))
								.addClass('text-error');
							});
		    			}
		    			
	    				return false;
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getRRUpdate();
				});
			},
			getRRUpdate: function () {
				this._getZoneListSelect();
			},
			//
			loadRRDelete: function () {
				var that = this,
					file, name;
				
				window.lim.loadPage('/_dns/rr_delete.html')
				.done(function (data) {
					$('#dns-content').html(data);
		    		$('#dns-content select').prop('disabled',true);
		    		$('#dns-content .selectpicker').selectpicker();
		    		$('#dns-content form').submit(function () {
			    		file = $('#dns-content select option:selected').text();
	    				name = $('#rrName').val();
	    				$('#dns-content #zoneFile').text(file);
	    				$('#dns-content #rrName').text(name);
	    				$('#deleteZoneRR').modal('show');
	    				return false;
		    		});
		    		$('#deleteZoneRR button.btn-primary').click(function () {
						$('#dns-content form').remove();
						$('#dns-content')
						.append($('<p></p>')
							.append($('<i></i>')
								.text('Deleting zone resource record '+name+' from zone file '+file+', please wait ...')
								));
		    			$('#deleteZoneRR').modal('hide');
	
						window.lim.delJSON('/dns/zone_rr', {
							zone: {
								file: file,
								rr: {
									name: name
								}
							}
						})
						.done(function (data) {
							$('#dns-content p')
							.text('Successfully deleted resource record option '+name+' from zone file '+file+'.')
							.addClass('text-success');
						})
						.fail(function (jqXHR) {
							$('#dns-content p')
							.text('Unable to delete resource record option '+name+' from zone file '+file+': '+window.lim.getXHRError(jqXHR))
							.addClass('text-error');
						});
		    		});
		    		$('#dns-content #submit').prop('disabled',true);
					that.getRRDelete();
				});
			},
			getRRDelete: function () {
				this._getZoneListSelect();
			},
		};
		window.lim.module.dns.init();
	});
})(window.jQuery);
