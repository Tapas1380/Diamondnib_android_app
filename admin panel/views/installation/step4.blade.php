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

                <h1 class="primary-color install-title">{{__('Label.import_software_database')}}</h1>
                <h1 class="install_sub_title">{{__('Label.database_connected')}}</h1>

                @if($backup == 0)
                    <h1 class="install_text">Click "<b>Import Database</b>" to begin. The import process may take some time.</h1>
                    <a href="{{ route('import_sql') }}" class="btn btn-install" onclick="showLoder()">{{__('Label.import_database')}}<i class="fa-solid fa-upload ml-2"></i></a>                
                @else
                    <h1 class="install_text">Before Proceeding, It's highly recommended to download a <b>BACKUP</b> of your current <b>DATABASE.</b> This ensures you can revert to the previous version if needed. Click "<b>Import Database</b>" to begin. The import process may take some time.</h1>
                    <a href="{{ route('import_sql') }}" class="btn btn-install mr-3" onclick="showLoder()">{{__('Label.import_database')}}<i class="fa-solid fa-upload ml-2"></i></a>
                    <a href="{{ route('backup_db', ['token'=>bcrypt('backup_db')]) }}" onclick="return confirm('{{__('Label.you_want_to_download_this_sql_file') }}')" class="btn btn-install-cancel">{{__('Label.backup_database')}}<i class="fa-solid fa-download ml-2"></i></a>
                @endif

                <!-- Footer -->
                @include('installation.layout.footer')

            </div>
        </div>
        <div class="col-lg-6 install-bg-img d-none d-lg-block">
            <img src="{{ asset('assets/imgs/install_bg.png') }}" alt="Software Installation">
        </div>
    </div>
@endsection