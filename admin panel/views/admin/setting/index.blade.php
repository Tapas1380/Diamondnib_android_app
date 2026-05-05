@extends('admin.layout.page-app')
@section('page_title', 'App Settings')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">App Settings</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">App Settings</li>
                    </ol>
                </div>
            </div>

            <ul class="nav nav-pills custom-tabs inline-tabs" id="pills-tab" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" id="app-tab" data-toggle="tab" href="#app" role="tab" aria-controls="app" aria-selected="true">{{__('Label.APP SETTINGS')}}</a>
                </li>
                @if( env('DEMO_MODE') == 'OFF')
                <li class="nav-item">
                    <a class="nav-link" id="smtp-tab" data-toggle="tab" href="#smtp" role="tab" aria-controls="smtp" aria-selected="false">SMTP</a>
                </li>
                @endif
            </ul>

            <div class="tab-content" id="pills-tabContent">
                <div class="tab-pane fade show active" id="app" role="tabpanel" aria-labelledby="app-tab">
                    <div class="card custom-border-card">
                        <h5 class="card-header">{{__('Label.App Settings')}}</h5>
                        <div class="card-body">
                            <form id="app_setting" enctype="multipart/form-data">
                                @csrf
                                <div class="form-row">
                                    <div class="col-md-9">
                                        <div class="form-row">
                                            <div class="form-group col-md-4">
                                                <label>{{__('Label.App Name')}}<span class="text-danger">*</span></label>
                                                <input type="text" name="app_name" value="@if($result && isset($result['app_name'])){{$result['app_name']}}@endif" class="form-control" placeholder="Enter App Name" autofocus>
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label>{{__('Label.Host Email')}}<span class="text-danger">*</span></label>
                                                <input type="email" name="host_email" value="@if($result && isset($result['host_email'])){{$result['host_email']}}@endif" class="form-control" placeholder="Enter Host Email">
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label>{{__('Label.App Version')}}<span class="text-danger">*</span></label>
                                                <input type="text" name="app_version" value="@if($result && isset($result['app_version'])){{$result['app_version']}}@endif" class="form-control" placeholder="Enter App Version">
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-4">
                                                <label>{{__('Label.Author')}}<span class="text-danger">*</span></label>
                                                <input type="text" name="author" value="@if($result && isset($result['author'])){{$result['author']}}@endif" class="form-control" placeholder="Enter Author">
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label>{{__('Label.Email')}} <span class="text-danger">*</span></label>
                                                <input type="email" name="email"  value="@if($result && isset($result['email'])){{$result['email']}}@endif" class="form-control" placeholder="Enter Email">
                                            </div>
                                            <div class="form-group  col-md-4">
                                                <label> {{__('Label.Contact')}} <span class="text-danger">*</span></label>
                                                <input type="text" name="contact" value="@if($result && isset($result['contact'])){{$result['contact']}}@endif" class="form-control" placeholder="Enter Contact">
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-4">
                                                <label>{{__('Label.WEBSITE')}}<span class="text-danger">*</span></label>
                                                <input type="text" name="website" value="@if($result && isset($result['website'])){{$result['website']}}@endif" class="form-control" placeholder="Enter Your Website">
                                            </div>
                                            <div class="form-group col-md-8">
                                                <label>{{__('Label.APP DESCRIPATION')}}<span class="text-danger">*</span></label>
                                                <textarea name="app_desripation" rows="1" class="form-control" placeholder="Enter App Desripation">@if($result && isset($result['app_desripation'])){{$result['app_desripation']}}@endif</textarea>
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-12">
                                                <label>Home Popup Video (MP4)</label>
                                                <input type="file" name="home_popup_video" class="form-control" accept="video/mp4,video/*">
                                                @if($result && isset($result['home_popup_video']) && $result['home_popup_video'] != '')
                                                    <small class="text-muted d-block mt-1">Current: <a href="{{$result['home_popup_video']}}" target="_blank">{{$result['home_popup_video']}}</a></small>
                                                @endif
                                                <input type="hidden" name="old_home_popup_video" value="@if($result && isset($result['home_popup_video'])){{$result['home_popup_video']}}@endif">
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <div class="form-group col-md-4">
                                                <label>Subscription</label>
                                                <select name="subscription_status" class="form-control">
                                                    <option value="1" @if($result && isset($result['subscription_status'])){{ $result['subscription_status'] == 1 ? 'selected' : ''}}@endif>On</option>
                                                    <option value="0" @if($result && isset($result['subscription_status'])){{ $result['subscription_status'] == 0 ? 'selected' : ''}}@endif>Off</option>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label>Subscription Price</label>
                                                <input type="number" name="subscription_plan_price" min="0" value="@if($result && isset($result['subscription_plan_price'])){{$result['subscription_plan_price']}}@endif" class="form-control" placeholder="Enter Subscription Price">
                                            </div>
                                            <div class="form-group col-md-4">
                                                <label>Subscription Period</label>
                                                <select name="subscription_plan_period" class="form-control">
                                                    <option value="week" @if($result && isset($result['subscription_plan_period'])){{ $result['subscription_plan_period'] == 'week' ? 'selected' : ''}}@endif>Weekly</option>
                                                    <option value="month" @if($result && isset($result['subscription_plan_period'])){{ $result['subscription_plan_period'] == 'month' ? 'selected' : ''}}@endif>Monthly</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group ml-5">
                                            <label class="ml-5">App Icon<span class="text-danger">*</span></label>
                                            <div class="avatar-upload ml-5">
                                                <div class="avatar-edit">
                                                    <input type='file' name="app_logo" id="imageUpload" accept=".png, .jpg, .jpeg" />
                                                    <label for="imageUpload" title="Select File"></label>
                                                </div>
                                                <div class="avatar-preview">
                                                    <img src="{{$result['app_logo']}}" alt="upload_img.png" id="imagePreview">
                                                </div>
                                            </div>
                                            <input type="hidden" name="old_app_logo" value="{{$result['app_logo']}}">
                                        </div>
                                    </div>
                                </div>
                                <div class="border-top pt-3 text-right">
                                    <button type="button" class="btn btn-default mw-120" onclick="app_setting()">{{__('Label.SAVE')}}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="col-6">
                            <div class="card custom-border-card">
                                <h5 class="card-header">API Configrations</h5>
                                <div class="card-body">
                                    <div class="input-group">
                                        <div class="col-2">
                                            <label class="pt-3" style="font-size:16px; font-weight:500; color:#1b1b1b">{{__('Label.API Path')}}</label>
                                        </div>
                                        <input type="text" readonly value="{{url('/')}}/api/" name="api_path" class="form-control" id="api_path">
                                        <div class="input-group-text ml-2" onclick="Function_Api_path()" title="Copy">
                                            <i class="fa-solid fa-copy fa-2xl"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card custom-border-card">
                                <h5 class="card-header">{{__('Label.Currency Settings')}}</h5>
                                <div class="card-body">
                                    <form id="save_currency">
                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label>{{__('Label.Currency Name')}}<span class="text-danger">*</span></label>
                                                <input type="text" name="currency" class="form-control" value="{{$result['currency']}}" placeholder="Enter Currency Name">
                                            </div>
                                            <div class="form-group col-md-6">
                                                <label>{{__('Label.Currency Code')}}<span class="text-danger">*</span></label>
                                                <input type="text" name="currency_code" class="form-control" value="{{$result['currency_code']}}" placeholder="Enter Currency Code">
                                            </div>
                                        </div>
                                        <div class="border-top pt-3 text-right">
                                            <button type="button" class="btn btn-default mw-120" onclick="save_currency()">{{__('Label.SAVE')}}</button>
                                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade" id="smtp" role="tabpanel" aria-labelledby="smtp-tab">
                    <div class="card custom-border-card">
                        <h5 class="card-header">{{__('Label.Email Setting [SMTP]')}}</h5>
                        <div class="card-body">
                            <form id="smtp_setting">
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                <input type="hidden" name="id" value="@if($smtp){{$smtp->id}}@endif">
                                <div class="form-row">
                                    <div class="form-group  col-md-3">
                                        <label>{{__('Label.IS SMTP Active')}}<span class="text-danger">*</span></label>
                                        <select name="status" class="form-control">
                                            <option value="">Select Status</option>
                                            <option value="0" @if($smtp){{ $smtp->status == 0  ? 'selected' : ''}}@endif>{{__('Label.No')}}</option>
                                            <option value="1" @if($smtp){{ $smtp->status == 1  ? 'selected' : ''}}@endif>{{__('Label.Yes')}}</option>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('Label.Host')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="host" class="form-control" value="@if($smtp){{$smtp->host}}@endif" placeholder="Enter Host">
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('Label.Port')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="port" class="form-control" value="@if($smtp){{$smtp->port}}@endif" placeholder="Enter Port">
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('Label.Protocol')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="protocol" class="form-control" value="@if($smtp){{$smtp->protocol}}@endif" placeholder="Enter Protocol">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group col-md-3">
                                        <label>{{__('Label.User name')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="user" class="form-control" value="@if($smtp){{$smtp->user}}@endif" placeholder="Enter User Name">
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('Label.Password')}}<span class="text-danger">*</span></label>
                                        <input type="password" name="pass" class="form-control" value="@if($smtp){{$smtp->pass}}@endif" placeholder="Enter Password">
                                        <label class="mt-1 text-gray">Search for better result <a href="https://support.google.com/mail/answer/185833?hl=en" target="_blank" class="btn-link">Click Here</a></label>
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('Label.From name')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="from_name" class="form-control" value="@if($smtp){{$smtp->from_name}}@endif" placeholder="Enter From Name">
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label>{{__('Label.From Email')}}<span class="text-danger">*</span></label>
                                        <input type="text" name="from_email" class="form-control" value="@if($smtp){{$smtp->from_email}}@endif" placeholder="Enter From Email">
                                    </div>
                                </div>
                                <div class="border-top pt-3 text-right">
                                    <button type="button" class="btn btn-default mw-120" onclick="smtp_setting()">{{__('Label.SAVE')}}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>

        // Sidebar Scroll Down
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);

        function Function_Api_path() {
            /* Get the text field */
            var copyText = document.getElementById("api_path");

            /* Select the text field */
            copyText.select();
            copyText.setSelectionRange(0, 99999); /* For mobile devices */

            document.execCommand('copy');

            /* Alert the copied text */
            alert("Copied the API Path: " + copyText.value);
        }

        function app_setting() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                var formData = new FormData($("#app_setting")[0]);
                $("#dvloader").show();
                $.ajax({
                    type: 'POST',
                    url: '{{ route("setting.app") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'app_setting', '{{ route("setting") }}');
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        }
        function save_currency() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                var formData = new FormData($("#save_currency")[0]);
                $("#dvloader").show();
                $.ajax({
                    type: 'POST',
                    url: '{{ route("setting.currency") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        $("html, body").animate({scrollTop: 0}, "swing");
                        get_responce_message(resp);
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        }
        function smtp_setting() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#smtp_setting")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("smtp.save") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        $("html, body").animate({scrollTop: 0}, "swing");
                        get_responce_message(resp);
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        }
    </script>
@endsection