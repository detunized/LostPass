// TODO: Remove this!
var is_chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;

var lastpass = (function (){
	var original_ajax = $.ajax;

	function override_function(f, new_f) {
		return (function () {
			var original_this = this;
			var original_arguments = arguments;
			new_f({
				arguments: original_arguments,
				original: f,
				call_original: function () {
					return f.apply(original_this, original_arguments);
				}
			});
		});
	}

	function override_ajax_callbacks(on_success, on_error) {
		$.ajax = override_function(original_ajax, function(ajax_context) {
			ajax_context.arguments[0].success = override_function(
				ajax_context.arguments[0].success, 
				on_success
			);

			ajax_context.arguments[0].error = override_function(
				ajax_context.arguments[0].error,
				on_error
			);
			
			return ajax_context.call_original();
		});
	}

	function restore_ajax() {
		$ajax = original_ajax;
	}
	
	function call_ios(call, parameters) {
		if (typeof parameters === 'undefined') {
			parameters = '';
		}

		var url = 'lastpass.' + call + ':' + parameters;
		if (is_chrome) {
			console.log(url);
		} else {
			window.location.href = url;
		}
	}

	var exported_api = {
		key: '',
		hash: '',
		database: '',

		download: function (email, password) {
			$('#email').val(email);
			$('#password').val(password);

			override_ajax_callbacks(
				function (context) {
					var response = $(context.arguments[0]);
					console.log(context.arguments[0]);
					var errors;
					if (response.find('ok').size() > 0) {
						exported_api.key = btoa(g_local_key);
						exported_api.hash = g_hash;
						call_ios('logged-in');
						exported_api.receive();
					} else if ((errors = response.find('error')).size() > 0) {
						errors.each(function() {
							var error = $(this);
							var iterations;
							var message;

							if ((iterations = error.attr('iterations')) > 0) {
								$('#iterations').val(iterations);
								login();
							} else if (message = error.attr('message')) {
								call_ios('login-failed', message);
							} else {
								call_ios('login-failed', 'Incorrect email or password.')
							}

							return; // Only test the first one
						});
					} else {
						call_ios('login-failed', 'Incorrect email or password.')
					}
				}, 
				function (context) {
					call_ios('login-failed', 'Cannot connect to the server.');
				}
			);

			login();
		},

		receive: function() {
			override_ajax_callbacks(
				function (context) {
					exported_api.database = context.arguments[0];
					call_ios('downloaded');
				},
				function (context) {
					call_ios('download-failed');
				}
			);
			
			getaccts();		
		}
	};

	alert = function (message) {
		call_ios('alert', message);
	}

	return exported_api;
})();
