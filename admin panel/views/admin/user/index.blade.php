@extends('admin.layout.page-app')
@section('page_title', __('Label.Users'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm"> {{__('Label.Users')}} </h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('Label.Users')}}</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('user.create') }}" class="btn btn-default mw-120" style="margin-top: -14px;">{{__('Label.Add_User')}}</a>
                </div>
            </div>

            <!-- Export Files -->
            <div class="page-search mb-3">
                <div class="col-8">
                    <label class="text-gray pt-2 font-weight-bold"><i class="fa-solid fa-circle-info fa-2xl mr-3"></i>Only the following data will be captured in this File.</label>
                </div>
                <div class="col-4">
                    <div class="d-flex justify-content-around">
                        <button id="ms_excel" class="btn btn-default" title="Download MS-Excel"><i class="fa-sharp fa-solid fa-file-excel mr-2 font-weight-bold"></i>MS-Excel</button>
                        <button id="csv" class="btn btn-default" title="Download CSV"><i class="fa-solid fa-file-csv mr-2 font-weight-bold" style="font-size:18px"></i>CSV</button>
                        <button id="pdf" class="btn btn-default" title="Download PDF"><i class="fa-solid fa-file-pdf mr-2 font-weight-bold" style="font-size:18px"></i>PDF</button>
                    </div>
                </div>
            </div>

            <!-- Search -->
            <div class="page-search mb-3">
                <div class="input-group" title="Search">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="input_search" class="form-control" placeholder="Search Users" aria-label="Search" aria-describedby="basic-addon1">
                </div>
                <div class="sorting mr-4">
                    <label>Sort by :</label>
                    <select class="form-control" id="input_type">
                        <option value="all">All</option>
                        <option value="today">Today</option>
                        <option value="month">Month</option>
                        <option value="year">Year</option>
                    </select>
                </div>
                <div class="sorting">
                    <label>Sort by :</label>
                    <select class="form-control" id="input_login_type">
                        <option value="all">All Type</option>
                        <option value="1">OTP</option>
                        <option value="2">Google</option>
                        <option value="3">Apple</option>
                        <option value="4">Normal</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr style="background: #F9FAFF;">
                            <th>{{__('Label.#')}}</th>
                            <th>{{__('Label.Image')}}</th>
                            <th>{{__('Label.Full_Name')}}</th>
                            <th>{{__('Label.Email')}}</th>
                            <th>{{__('Label.Mobile')}}</th>
                            <th>Register Date</th>
                            <th>{{__('Label.Type')}}</th>
                            <th>Login Type (1-OTP, 2-Google, 3-Apple, 4-Normal)</th>
                            <th>{{__('Label.Action')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        $(document).ready(function() {
            var table = $('#datatable').DataTable({
                dom: "<'top'f>rt<'row'<'col-2'i><'col-1'l><'col-9'p>>",
                searching: false,
                responsive: true,
                autoWidth: false,
                processing: true,
                serverSide: true,
                lengthMenu: [
                    [10, 100, 500, -1],
                    [10, 100, 500, "All"]
                ],
                language: {
                    paginate: {
                        previous: "<i class='fa-solid fa-chevron-left'></i>",
                        next: "<i class='fa-solid fa-chevron-right'></i>"
                    }
                },
                ajax: {
                    url: "{{ route('user.index') }}",
                    data: function(d) {
                        d.input_type = $('#input_type').val();
                        d.input_login_type = $('#input_login_type').val();
                        d.input_search = $('#input_search').val();
                    },
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex'
                    },
                    {
                        data: 'image',
                        name: 'image',
                        orderable: false,
                        searchable: false,
                        render: function(data, type, full, meta) {
                            return "<a href='" + data + "' target='_blank' title='Watch'><img src='" + data + "' class='rounded-circle' style='height:55px; width:55px'></a>";
                        },
                    },
                    {
                        data: 'full_name',
                        name: 'full_name',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'email',
                        name: 'email',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'mobile_number',
                        name: 'mobile_number',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'date',
                        name: 'date'
                    },
                    {
                        data: 'type',
                        name: 'type',
                        orderable: false,
                        searchable: false,
                        render: function(data, type, full, meta) {
                            if (data == 1) {
                                return "<i class='fa-solid fa-mobile-screen-button fa-3x' title='OTP Login'></i>";
                            } else if (data == 2) {
                                return "<i class='fa-brands fa-google fa-3x' title='Goggle Login'></i>";
                            } else if (data == 3) {
                                return "<i class='fa-brands fa-apple fa-3x' title='Apple Login'></i>";
                            } else if (data == 4) {
                                return "<i class='fa-solid fa-lock fa-3x' title='Normal Login'></i>";
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'type',
                        name: 'Login Type',
                        orderable: false,
                        searchable: false,
                        visible: false,
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'action',
                        name: 'action',
                        orderable: false,
                        searchable: false
                    },
                ],
                buttons: [{
                        extend: 'excel',
                        filename: "{{App_Name()}} - Users",
                        exportOptions: {
                            columns: [0, 2, 3, 4, 5, 7]
                        },
                        customize: function(xlsx) {
                            var sheet = xlsx.xl.worksheets['sheet1.xml'];
                            $('row:first c', sheet).attr('s', '2');
                        },
                    },
                    {
                        extend: 'csv',
                        filename: "{{App_Name()}} - Users",
                        exportOptions: {
                            columns: [0, 2, 3, 4, 5, 7]
                        },
                    },
                    {
                        extend: 'pdf',
                        title: "{{App_Name()}} - Users",
                        filename: "{{App_Name()}} - Users",
                        pageSize: 'A4',
                        exportOptions: {
                            columns: [0, 2, 3, 4, 5, 7]
                        },
                        customize: function(doc) {
                            doc.styles.tableHeader.fontSize = 10; //2, 3, 4, etc
                            doc.defaultStyle.fontSize = 8; //2, 3, 4,etc
                            doc.content[1].table.widths = ['5%', '20%', '20%', '20%', '15%', '20%'];
                            doc.content[1].layout = "borders";
                            doc.styles.title.fontSize = 22;
                            doc.styles.title.alignment = 'center';
                            doc.defaultStyle.alignment = 'center';

                            // Create a header
                            doc['header'] = (function(page, pages) {
                                return {
                                    columns: [{
                                            alignment: 'left',
                                            bold: true,
                                            text: "{{App_Name()}}",
                                        },
                                        {
                                            alignment: 'right',
                                            bold: true,
                                            text: ['Total Page ', {
                                                text: pages.toString()
                                            }],
                                        }
                                    ],
                                    margin: [20, 20],
                                }
                            });
                            // Create a footer
                            doc['footer'] = (function(page, pages) {
                                return {
                                    columns: [{
                                        alignment: 'center',
                                        bold: true,
                                        text: ['Page ', {
                                            text: page.toString()
                                        }, ' of ', {
                                            text: pages.toString()
                                        }],
                                    }],
                                }
                            });
                        }
                    }
                ],
            });

            $('#ms_excel').on('click', function() {

                var check_access = '{{Check_Admin_Access()}}';
                if (check_access == 1) {
                    var table = $('#datatable').DataTable();
                    table.button('0').trigger();
                } else {
                    toastr.error("You have no right to Download This Files.");
                }
            });
            $('#csv').on('click', function() {

                var check_access = '{{Check_Admin_Access()}}';
                if (check_access == 1) {
                    var table = $('#datatable').DataTable();
                    table.button('1').trigger();
                } else {
                    toastr.error("You have no right to Download This Files.");
                }
            });
            $('#pdf').on('click', function() {

                var check_access = '{{Check_Admin_Access()}}';
                if (check_access == 1) {
                    var table = $('#datatable').DataTable();
                    table.button('2').trigger();
                } else {
                    toastr.error("You have no right to Download This Files.");
                }
            });

            $('#input_type, #input_login_type').change(function() {
                table.draw();
            });
            $('#input_search').keyup(function() {
                table.draw();
            });
        });
    </script>
@endsection