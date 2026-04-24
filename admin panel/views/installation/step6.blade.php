@extends('installation.layout.page-app')

@section('content')
    <div class="row">
        <div class="col-md-12 col-lg-12 col-xl-6 d-flex flex-column justify-content-center">
            <div class="install-card">

                <!-- Alert MSG -->
                @if(session()->has('error'))
                    <div class="alert alert-danger alert-block">
                        <button type="button" class="close" data-dismiss="alert" title="Remove">X</button>
                        <strong>{{ Session::get('error') }}</strong>
                    </div>
                @elseif(session()->has('success'))
                    <div class="alert alert-danger alert-block">
                        <button type="button" class="close" data-dismiss="alert" title="Remove">X</button>
                        <strong>{{ Session::get('success') }}</strong>
                    </div>
                @endif

                <h1 class="primary-color install-title">{{__('Label.congratulations')}}</h1>
                <h1 class="install_sub_title">{{__('Label.the_admin_panel_installation_has_been_completed_successfully_click_the_below_button_to_access_it_and_begin_managing_your_application')}}</h1>
                <div class="mt-3">
                    <a href="{{ route('admin.login') }}" onclick="showLoder()" class="btn btn-install">{{__('Label.admin_panel')}}</a>
                </div>

                <!-- Footer -->
                @include('installation.layout.footer')

            </div>
        </div>
        <div class="col-lg-6 install-bg-img d-none d-lg-block">
            <img src="{{ asset('assets/imgs/install_bg.png') }}" alt="Software Installation">
        </div>
    </div>
@endsection