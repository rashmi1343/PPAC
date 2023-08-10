import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constant.dart';

class Webview extends StatefulWidget {
  String slugname;

  Webview({required this.slugname});

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  var isdownload = false;
  String _progress = "-";
  var dio = Dio();



  String setHTML(String pagecontent) {

    return ('''
    <html>
      <head>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
     <link rel="stylesheet" href=
"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
        
      </head>
      
    
      <style>
        
:root{
    --fw300: 'Graphik Light';
    --fw400: 'Graphik Regular';
    --fw500: 'Graphik Medium';
    --fw600: 'Graphik Semibold';
    --fw700: 'Graphik Bold';
}

#lupdateddate{
   color:darkgreen;
}

body .cpd-tab li.list-group-item.active,
.list-group-item.active {
    background-color: #789bb3;
    border-color: #ccc;
    
}

body .cpd-tab li.list-group-item.active a{
    font-weight: 400;
}

.list-group-item.active a{
    color: #fff ;
}

.logo-search ::placeholder,
.logo-search *{
    font-size:15px !important;   
}

html{
    font-size: 57.5%;
    scroll-behavior: smooth;
    scroll-padding-top: 75px;
}
body{    
    font-family: 'Graphik Regular';
    margin: auto;
    width: 100%;
    height: 100%;     
    max-width: 1920px;
    color: #111111;
    overflow-x: hidden;
    padding-right: 0px !important;
}
.sticky {
  position: fixed;
  width: 100%;
  left: 0;
  top: 0;
  z-index: 100;
  border-top: 0;
}
.cpd-tab li.list-group-item.active {
    background-color: transparent;
}
.cpd-tab li.list-group-item.active a {
    font-weight: 900;
}
.price-list li{
    position: relative;
    margin: 16px;
        width: 33.33%;
}
.orgstrucure .sec_ind .fa-light:before{
    margin-left:10px;
    color:#fff;
}
.price-list a {
    display: flex;
    color: #111;
    align-items: center;
    background: white;
    padding:20px;
    padding-left: 94px;
    box-shadow: 1px 2px 10px rgb(0 0 0 / 20%);
    border-radius: 5px;
        height: 100%;
}
.price-list a:hover{
    color:#085196;
}
ul.price-list.xls-icon li {
    margin-left: 0;
}
.price-list.xls-icon li:before{
    content:'\f1c3';
}
.price-list.xls-icon li.pdf:before{
    content:'\f1c1';
}
.price-list li:before{
    content: '\f08e';
    position: absolute;
    margin: auto;
    left: 35px;
    font-family: "Font Awesome 6 Pro";
    font-weight: 400;
    top: 0;
    bottom: 0;
    font-size: 48px;
    color: #085196;
    height: 53px;
}
.bredcrum span {
    /*text-transform: lowercase;*/
    font-weight:500 !important;
}
.bredcrum::first-line{
  text-transform: capitalize !important;
}
/*Go to top*/
.go-top {
       position: fixed;
    bottom: 1%;
    right: 1%;
    display: none;
    cursor: pointer;
    -webkit-font-smoothing: antialiased;
    background-color: #085196;
    color: #fff;
    border-radius: 3px;
    font-size: 24px;
    padding: 7px 20px;
    padding-bottom: 1px;
}

/*Go to top*/
.iprr .checkList-a li a:hover {
    color: #085196;
  
}
.about ul li a:hover {
    text-decoration: underline;
}
.refeniry::-webkit-scrollbar {
  /*width: .9em;
   height: .9em;*/
  }
.refeniry::-webkit-scrollbar-track {
  /*background-color: #ececec;*/
}
::placeholder { /* Chrome, Firefox, Opera, Safari 10.1+ */
    font-size:1.6rem;
    color: #111111;
    font-family: var(fw400);
  }
  
  :-ms-input-placeholder { /* Internet Explorer 10-11 */
    font-size:1.6rem;
     color: #111111;
     font-family: var(--fw400);
  }
  
  ::-ms-input-placeholder { /* Microsoft Edge */
    font-size:1.6rem;
     color: #111111;
     font-family: var(fw400);
  }
  .text-dark {
    color: #111111!important;
}
.refeniry::-webkit-scrollbar-thumb {
  /*background-color: #085196;*/
}
.gallery-col{
    background-color:#007a35;
    padding: 25px 15px;
}
.gallery-inner-col {
    max-width: 655px;
}

.notification-inner-col .tab-content {
    display: flex;
    height: 100%;
}

.partner-sec ul li{
    /* max-width: 188px; */
    margin: 15px 0px;
    border: 1px solid #eee;
    padding: 0px;
}

body .partner-sec .item img{
    display:inline;
    width:auto;
}

.partner-sec .container{
    max-width:1300px;
}

.owl-carousel .owl-item{
    text-align:center;
}

.notification-col {
    background-image: url(../images/notifaction-bg.jpg);
    background-repeat: no-repeat;
    padding: 25px 30px;
    color: #fff;
    background-size: cover;
}
.notification-col .nav-link, .gallery-inner-col .nav-link{
    display: block;
    padding: 0rem 1rem !important;
    color: #ffffff !important;
    text-decoration: none;
    transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out;
    font-size: 1.8rem;
    font-family: var(--fw600) !important;
    border-right: 1px solid #fff;
    line-height: 23px;
}
.feedback-col {
    right: -66px;
    z-index: 2;
    top: 49%;
    transform: rotate(90deg);
}

.feedback-col + .register {
    top:auto;
    bottom: 17%;
}

.feedback-col .common-btn{
    background-color: #f07906 !important;
    color: #fff !important;
}
.notification-col .nav-tabs .nav-item.show .nav-link, .notification-col .nav-tabs .nav-link.active{
    color: #fbd10a !important;
    border-color: transparent;
    background-color: transparent;
    border-right: 1px solid #fff;
}
.gallery-inner-col .nav-tabs .nav-link.active{
    color: #fbd10a !important;
    border-color: transparent;
    background-color: transparent;
}
.notification-col .nav-tabs .nav-item .nav-link:hover{
    border-top: 1px solid transparent !important;
    border-bottom: 1px solid transparent !important;
    border-left: 1px solid transparent !important;
}
.gallery-inner-col .nav-tabs .nav-item .nav-link{
    border-top: 1px solid transparent !important;
    border-bottom: 1px solid transparent !important;
    border-left: 1px solid transparent !important;
        border-right: 1px solid #fff;
}
.modal-backdrop.show {
    width: 100%;
    height: 100%;
}
/*onload css*/
.onload-slider .modal-dialog {
    max-width: 1280px;
    width:100%;
    padding: 0px 30px;
}
.onload-slider .modal-body {
    padding: 0;
}
.onload-slider .btn-close, .feedback-slider  .btn-close{
    position: absolute;
    right: -31px;
    z-index: 10;
    background-color: #f8d116;
    opacity: 1;
    height: 43px;
    width: 43px;
    border-radius: 50%;
    font-weight: 500;
    top: -17px;
    padding: 0;
}
.feedback-slider h3{
    background-color: #f3f3f3;
    padding: 15px 30px;
    border-radius: 5px 0px 5px 0px;
}
.feedback-slider .modal-content{
   border-radius: 5px;   
}
.onload-slider .owl-carousel .owl-nav button.owl-next, .onload-slider .owl-carousel .owl-nav button.owl-prev{
    background-color: rgba(0,0,0,.8);
    padding: 10px 20px !important;
    border-radius: 5px 0px 0px 5px;
}
.onload-slider .owl-nav span {
    color: #f8d116;
}
.onload-slider .owl-carousel .owl-nav button.owl-prev{
    border-radius: 0px 5px 5px 0px;
}
/*TH stkey css*/
table.refeniry {
  position: absolute;
  border-collapse: transparent;
}

.refeniry thead {
       position: -webkit-sticky;
    position: sticky;
    top: -1px;
    
    
    border-right: 1px solid black !important;
    border-top: 1px solid #000 !important;
    /* border: 0px !important; */
    border: 1px solid #ededed !important;
    /* text-align: center !important; */
    box-shadow: 0px 2px 0 0 #eee;
    background: #eee;
}
.table-hover>tbody>tr:hover {
    --bs-table-accent-bg: var(--bs-table-hover-bg) !important;
   
}
.refeniry thead th:first-child {
  left: 0;
  z-index: 1;
}
.fix_col tbody th {
    /*border: 0px !important;*/
    border-bottom: 1px solid #ededed !important;
}
.refeniry td {
    /*border: 0px !important;*/
    border-bottom: 1px solid #ededed !important;
    /*text-align: right;*/
        font-size: 14px;

}
/*TH stkey css*/
.home-banner-wrapper{
    /*overflow:hidden;*/
}
.child-menu ul li a {
    font-size: 1.5rem;
    padding: 10px 12px;
}
.gallery-tab li.nav-item button.active, .gallery-tab li.nav-item button:hover {
    font-weight: 600;
    border: 0;
    color: #085196;
    border-bottom: 3px solid #085196;
}
.gallery-tab li.nav-item button {
    font-size: 1.8rem;
    font-weight: 600;
    color: #6e6e6e;
    border: 0;
    border-bottom: 3px solid transparent;
    padding: 5px 25px;
}
/*pagination*/
.pagination {
    justify-content: center;
}
.pagination .page-link{
    position: relative;
    display: block;
    color: #033667;
    border: 0;
    font-size: 18px;
    border-radius: 2px;
        margin: 0px 3px;
        padding: 1px 12px;
}
.pagination .page-link span{
    font-size: 18px;
}
.pagination .page-link:hover, .pagination .page-item.active .page-link{
    background-color: #007a35;
    color: #fff;
}
/*pagination*/
#photo figure a, #video figure a {
    max-height: 220px;
    overflow: hidden;
    display: block;
}
/*Loder css*/
.loader-sec {
    position: fixed;
    height: 100%;
    width: 100%;
    top: 0;
    background-color:#000000e0;
    z-index: 100;
    display: none;
    align-items: center;
}
.loader,
.loader:before,
.loader:after {
  background:#007a35;
  -webkit-animation: load1 1s infinite ease-in-out;
  animation: load1 1s infinite ease-in-out;
  width: 1em;
  height: 4em;
}
.loader {
  color: #007a35;
  text-indent: -9999em;
  position: relative;
  font-size: 11px;
  -webkit-transform: translateZ(0);
  -ms-transform: translateZ(0);
  transform: translateZ(0);
  -webkit-animation-delay: -0.16s;
  animation-delay: -0.16s;
  position: absolute;
    margin: auto;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
}
.loader:before,
.loader:after {
  position: absolute;
  top: 0;
  content: '';
}
.loader:before {
  left: -1.5em;
  -webkit-animation-delay: -0.32s;
  animation-delay: -0.32s;
}
.loader:after {
  left: 1.5em;
}
@-webkit-keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}
@keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}

/*Loder css*/
select{
    background-image: url(../images/select-angle.png);
    background-repeat: no-repeat;
    background-position: right 8px center;
}
a, .text-blue{
    color: #085196;
}
.border-blue{
   border-color: #085196 !important; 
   display:none;
}
.about ul li:last-child a {
    border-right: 0 !important;
}
.about ul li:first-child a {
    padding-left:0px !important;
}
.border-res{
    border:1px solid #085196;
    padding: 14px 30px !important;
}
.border-res:hover{
    background-color:#085196 !important;
    color:#fff !important;
}
figure.main-img-gal {
    height:185px;
    overflow: hidden;
}
select option{
    padding: 5px;
}
select.no-select-angle{
    background-image: none;
}
.text-light-grey{
    color: #535353 !important;
}
.text-blue{
    color: #085196 !important;
}
.text-yellow{
    color: #fbd10a !important;
}
.bg-yellow{
    background-color: #fbd10a !important;
}
.border-blue{
    border-color: #085196 !important;
     display:none;
}
.bg-blue{
    background-color: #085196 !important;
}

.bg-sky-blue{
    background-color:#e1ecf6;
}
.bg-sky-light-blue{
    background-color:#f7fafc;
}

.bg-light-sky-blue{
    background-color: #f2f6fa;
}
.text-green{
    color: #007a35;
    margin:10;
}

.common-btn.bg-green{
    background-color: #007a35;
    color: #fff;
}
.common-btn.bg-green:hover{
    background-color: #085196;
    color: #fff;
}


.badge-notification{
    color: #004085;
    background-color: #dfedfd;
    line-height: normal;
}
.badge-act{
    color: #155724;
    background-color: #e3f1ea;
}
.badge-grade-c{
    color: #856404;
    background-color: #f9f4e3;
}
.badge-grade-a{
    color: #0c5460;
    background-color: #e8f3f7;
}

.fw300{
    font-family:var(--fw300) !important;
}
.fw400{
    font-family:var(--fw400) !important;
}
.fw500{
    font-family:var(--fw500) !important;
}
.fw600{
    font-family:var(--fw600) !important;
}
.fw700{
    font-family:var(--fw700) !important;
}


p,input,button,select,textarea, span,a ,div, .form-control{
    font-size: 1.4rem
}


.fz12{
    font-size: 1.2rem !important;
}
.fz13{
    font-size: 1.3rem !important;
}
.fz14, .dropdown-toggle{
    font-size: 1.4rem !important;
}
.fz15{
    font-size: 1.5rem !important;
}
.fz16{
    font-size: 1.6rem !important;
}
.fz18{
    font-size: 1.8rem !important;
}
.fz20{
    font-size:2rem !important;
}
.fz22{
    font-size: 2.2rem !important;
    
}
.fz24{
    font-size: 2.4rem !important;
}
.fz26{
    font-size: 2.6rem !important;
}
.fz28{
    font-size: 2.8rem !important;
}
.fz30{
    font-size: 3rem !important;
}
.fz32{
    font-size: 3.2rem !important;
}
.fz34{
    font-size: 3.4rem !important;
}
.fz36{
    font-size: 3.6rem !important;
}
.fz38{
    font-size: 3.8rem !important;
}
.fz40{
    font-size: 4rem !important;
}
.outline-0
{
    outline: none;

}
.new-batch {
    background-color: #dd1717a6;
    font-size: 11px;
    color: #fff;
    line-height: 15px;
    padding: 1px 5px;
    border-radius: 5px;
}
.btn-group{
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 1.4rem;
}

.btn-group *{
    border-radius: 4px !important;
}

ul{ padding: 0px; margin: 0px; list-style-type:none;}

.btn{
    font-size: 1.4rem;
    white-space: nowrap;
     text-align:right;
}
a{
    text-decoration: none;
}

/*dropdown css*/
.nav-ppac ul li {
    position: relative;
}
.nav-ppac ul ul {
    border: 1px solid #eee;
    position: absolute;
    background-color: #f8f9fa;
    min-width: 200px;
    z-index: 30;
    -webkit-transition: .3s ease;
    -o-transition: .3s ease;
    transition: .3s ease;
    visibility: hidden;
    opacity: 0;
}
.nav-ppac ul > li:hover > ul {
    margin-top: 9px;
    visibility: visible;
    opacity: 1;
}
.nav-ppac ul ul ul {
    left: 100%;
    top: 0;
    margin-top: 0 !important;
}
.nav-ppac .sub-child-menu:after {
    content: "\f107";
    font-family: 'Font Awesome 5 Pro';
    color: #fff;
    position: absolute;
    color: #000;
    right: 15px;
    top: 8px;
    -webkit-transform: rotate(-90deg);
    -ms-transform: rotate(-90deg);
    transform: rotate(-90deg);
}
.nav-ppac .child-menu:after {
    content: "\f107";
    font-family: 'Font Awesome 5 Pro';
    color: #fff;
    font-weight: 800;
    position: absolute;
    right: 10px;
    top: 9px;
}
.nav-ppac .child-menu:hover:after {
    color: #000;
}
.nav-ppac ul ul li:hover > a {
    background-color: #fff;
    color: #f07906;
}
.nav-ppac ul > li > ul {
    margin-top: 20px;
}
.nav-ppac ul > li:hover > ul {
    margin-top: 0px;
    visibility: visible;
    opacity: 1;
}
/*dropdown css*/
/* top-strip */
.top-strip{
    background-color: #ededed;
}

.top-strip li{
    color: #111111;
    font-size: 1.4rem;
    font-family: var(--fw400);
}
.top-strip li:hover a{
    color: #085196;
}
.top-strip li a{
    color: inherit;
}
.top-strip li:after{
    content: '|';
    margin: 0 6px;
}
.top-strip li:last-child::after {
    content: none   ;
}

#change_language{
    padding-right:2.7rem !important;
    transform: translateX(6px);
}

/* header-search */
.header-search{
    width: 100%;
    max-width: 350px;
}
.header-search i{
    position: absolute;
    left: 20px;
    font-size: 2rem;
    color: #085196;
    top: 0;
    bottom: 0;
    pointer-events: none;
    margin: auto;
    height: 21px;
}
.header-search .form-control{
    height: 42px;
    padding-left: 50px;
    color: #6e6e6e;
    font-size: 1.8rem;
}

/* header-navigation */
.header-navigation li a{
    font-size: 1.6rem;
    font-family: var(--fw400);
    color: #fff;
    padding:8px 28px;
    display: block;
}

.header-navigation .child-menu a{
    padding:8px 32px 8px 16px;
}

.header-navigation .nav-ppac > ul > li > a{
    text-transform: uppercase;
}


.logo img.img-fluid {
    max-width:80%;
}
.ashok-img img.img-fluid {
    max-width:100%;
}
.header-navigation li:hover a, .header-navigation li.active a{
    background-color: #f2f6fa;
    color: #000;
}
.contact-frm input.form-control, .feedback-slider input.form-control{
    height: 46px;
    border-radius: 5px;
    border-color: #b6b6b6;
    margin-bottom: 20px;
    box-shadow: none;
    padding-left: 15px;
}

.contact-frm textarea, .feedback-slider textarea{
    border-radius: 5px;
    border-color: #b6b6b6;
    padding-left: 15px;
}
/* owl-nav */
.owl-nav{
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    width: 100%;
    pointer-events: none;
    display: flex;
    justify-content: space-between;    
}
.owl-nav span{
    font-size: 0;
    width: 50px;
    height: 50px;    
    pointer-events: all;
}
.owl-nav .owl-prev span:after{
    content: "\f060";

}
.owl-nav .owl-next span:after{
    content: "\f061";
}

.owl-nav span:after{
    font-family:"Font Awesome 6 Pro";
    font-size: 2.8rem;
    font-weight: 600;
}

.offset-arrow-slider .owl-nav .owl-prev, .partner-slider .owl-nav .owl-prev{
    margin-left:-65px
}
.offset-arrow-slider .owl-nav .owl-next , .partner-slider .owl-nav .owl-next{
    margin-right:-65px
}
.offset-arrow-slider .owl-nav span:after , .partner-slider .owl-nav span:after{
    font-size: 22px;
    color: #fad00b;
}
.offset-arrow-slider .owl-nav span , .partner-slider .owl-nav span {
    border: 1px solid #fad00b;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
}
.offset-arrow-slider .owl-nav span:hover,  .partner-slider .owl-nav span:hover{
    border: 1px solid #fad00b;
    background:#fad00b;
}
.offset-arrow-slider .owl-nav span:hover:after, .partner-slider .owl-nav span:hover:after{
   color:#000;
}
/* banner-sliders */

.banner-sliders .item{
    position: relative;
}
.banner-content{
    position: absolute;
    width: 100%;
    top: 50%;
    transform: translateY(-50%);
}
.banner-content h3{
    font-size: 5.5rem;
    font-family: var(--fw700);
    max-width: 650px;
    color: #fff;
    margin-bottom: 40px;
}

.banner-content a{
    border: 2px solid;
    font-size: 1.8rem;
    font-family: var(--fw600);
    color: #fff;
    background-color: #007a35;
    width: 180px;
    padding: 9px 0;
    border-radius: 7px;
    letter-spacing: .4px;    
    border-color: #fff;
}

.banner-content a:hover{
    background-color:#085196;
    color: #fff;
    border-color: #085196;
}

.banner-sliders .owl-nav{
    padding: 0 70px;
}
.banner-sliders .owl-nav span{
    color: #fff;
    border: 1px solid;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
}
.banner-sliders .owl-nav span:hover{
    background-color: #085196;
    border-color: #085196;
}

/* common-btn */
.common-btn{
    background-color: #085196;
    color: #fff;
    font-size: 1.8rem;
    padding: 15px 30px;
    display: inline-block;
    border-radius: 5px;
    box-shadow: 0 .5rem 1rem rgba(0,0,0,.15);
    font-family: var(--fw600) !important;
    line-height: 1.1;
}
.common-btn:hover{
    color: #fff;
    background-color: #007a35;
}

/* common-section */
.common-section{
    padding:5px 0;
}
.common-section .title{
    font-size:3.5rem;
    font-family: var(--fw700);
}
.common-section .desc{
    font-size: 1.8rem;    
}
.snapshot-bg h2, .snapshot-bg h3, .snapshot-bg h4, .snapshot-bg p, .snapshot-bg .checkList-a li a{
    color: #fff;
    
}
.snapshot-bg .checkList-a li::before {
    color:#fff;
    
}
.snapshot-bg .common-btn {
    background-color: #fbd10a !important;
    color:#111111;
}
.snapshot-bg .common-btn:hover{
        box-shadow: 0 0.5rem 1rem rgb(0 0 0 / 35%);
}
.snapshot-bg figure{
    border-radius: 5px;
    overflow: hidden;
}
/* snapshot-bg */
.snapshot-bg{
    background: url(../images/arr-bg.jpg) no-repeat;
    background-size: cover;
}

/* checkList */
.snapshot-bg ul.checkList-a li {
    color: #fff;
    
}
.checkList-a li
.checkList-a li a , 
.checkList li{
    display: block;
    margin-bottom:5px;
    font-size: 1.8rem;
    display: flex;
    color: #000;
      
}
/*.checkList-a li a{*/
/*    text-decoration: underline;*/
/*}*/
.checkList-a li a:hover{
    color:#fbd10a;
  
}
.checkList-a li::before {
    content: '\f058';
    font-family: "Font Awesome 6 Pro";
    margin-right: 15px;
}
// .checkList-a li::before{
//  
//     font-family: "Font Awesome 6 Pro";
//     content: '\f058';
//     font-weight: 400;
//     margin-right: 1px;
//     color:#000;
//     font: var(--fa-font-regular);
//      
//   
// }

/* important-reports-slider */
.important-reports-slider .item{
    padding: 25px;
    display: flex;
    flex-direction: column;
    height:100%;
        transition: .3s;
        justify-content:center;
    margin: 5px;
    border: 1px solid #6d8ead;
        border-radius: 5px;

}
.important-reports-slider .item a{
        display: flex;
    flex-direction: column;
    height:100%;
}

.important-reports-slider .item h3{
        margin: auto !important;
        font-size: 18px !important;
}
.imp-report-sec .owl-carousel .owl-stage {
    display: flex;
}
.important-reports-slider .owl-item .item:hover{
     background-color: #007a35; 
    border-radius: 5px;
    border-color:#eee;
    transform: scale(1.02);
}

.important-reports-slider .owl-item{
    padding-bottom:10px;
}
.border-notify-right{
    border-right: 1px solid #b7cde1;
}
.media-gallery figure{
    margin-bottom: 0;
    border: 1px solid #fff;
    border-radius: 5px;
}
.main-img-gal figcaption{
        position: absolute;
    bottom: 0;
    width: 80%;
    background-color: rgb(0 0 0 / 76%);
    font-size: 16px;
    color: #fbd10a;
    align-items: center;
    padding: 5px 20px;
    left: 0;
    right:10;
    font-weight: 600;
}
.media-gallery .col-6 figure{
    position: relative;
        height:85px;
    overflow: hidden;
}
.copyrught p {
    color: #fff;
}
.copyrught p + p {
    margin-bottom: 0;
}
.partner-slider .owl-nav {
   
}
.copyrught p a {
    color: #fff;
}
.pan01 .data_b1 + .data_b1 .form-control.sty01 {
    display: inline-block;
    width: 180px;
}
.media-gallery .col-6 figure:after{
    content: '\f065';
    background-color: rgb(0 0 0 / 90%);
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;
    position: absolute;
    pointer-events: none;
    opacity: 0;
    visibility: hidden;
    font-family: "Font Awesome 6 Pro";
    font-weight: 400;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
}
.gallery-page .media-gallery .col-6 figure {
    position: relative;
    max-height: 327px;
    overflow: hidden;
    height: auto;
}
.media-gallery .col-6 figure:hover:after{
    opacity:1;
    visibility: visible;
}

/* main-footer */
.main-footer{
    background-color: #252525;
    border-bottom: 1px solid #99999952;
    
}
.middle-footer{
    background-color: #252525;
    padding: 20px 0;
}

.middle-footer a{
    font-size: 2.2rem;
    color: #fff;
}
.footer-social-media a{
    border: 1px solid #333333;
    width: 60px;
    height: 60px;
    border-radius: 0px !important;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color:#151515;
}
.footer-social-media a:hover{
    color: #007a35;
}
.main-footer h4{
    color: #fff;
    font-size: 2.2rem;
    font-family: var(--fw600) !important;
}
.main-footer a{
    color: #fff;
    font-size: 1.8rem;
    font-family: var(--fw400);
}
.main-footer a.common-btn {
    font-size: 1.8rem;
}
.main-footer a:hover{
    color: #aaa;
}
.main-footer  ul li{
    margin-bottom: 6px;
}
.copyrught{
    background-color: #151515;
    padding: 10px 0;
}


.grphbx{
	background:#fff;
	box-shadow:0 0 12px rgba(0,0,0,0.12);
	padding:40px;
	margin-right:40px;
	margin-top:20px;
	position:relative;
}

.grphbx:before{
	content:"";
	position:absolute;
	z-index:-1;
	right:-40px;
	top:-40px;
	background:#007a35;
	width:50%;
	max-width:600px;
	bottom:40px;
}

.btn_ppac01{
display: flex;
justify-content: center;
align-items: center;
	    font-size: 15px;
    color: #fff;
    background-color: #085196;
    border-color: #085196;
    padding: 8px 17px;
    visibility: visible;
	  text-align: right;
	 

}
.btn_ppac01:focus,
.btn_ppac01:hover{
	color:#fff;
 background-color: #085196;
        outline:none;
          
}


.pan01 .rigt_s{
	flex:1;
}

.pan01 .data_b1 + .data_b1{
	margin-left:30px;
}

.form-control.sty01{
	display:inline-block;
	width:120px;
	border:0;
	color:#085196;
	font-size:16px;
}

b.tx01{
	color:#085196;
}

table.sty01 a{
	color:#007a35;
	
}

table.sty01 thead th{
         text-transform: uppercase;
    background: #085196 !important;
    border-bottom: 1px solid #085196 !important;
    color: #fff;
    padding: 10px;
    font-weight: 500;
    text-align: center;
    font-size: 16px;
    
}
table.sty01 thead td {
    background-color: #fff !important; 
     border-spacing: 0px;
}

.table>:not(caption)>*>*{
	padding:1rem;
	border-bottom:1px solid #ededed;
}

.table_right_align_nth_1 tr td:nth-child(1), 
.table_right_align_nth_1 tr th:nth-child(1){
    text-align:right;
}
.table_right_align_nth_2 tr td:nth-child(2), 
.table_right_align_nth_2 tr th:nth-child(2){
    text-align:right;
}
.table_right_align_nth_3 tr td:nth-child(3), 
.table_right_align_nth_3 tr th:nth-child(3){
    text-align:right;
}
.table_right_align_nth_4 tr td:nth-child(4), 
.table_right_align_nth_4 tr th:nth-child(4){
    text-align:right;
}
.table_right_align_nth_5 tr td:nth-child(5), 
.table_right_align_nth_5 tr th:nth-child(5){
    text-align:right;
}
.table_right_align_nth_6 tr td:nth-child(6), 
.table_right_align_nth_6 tr th:nth-child(6){
    text-align:right;
}
.table_right_align_nth_7 tr td:nth-child(7), 
.table_right_align_nth_7 tr th:nth-child(7){
    text-align:right;
}
.table_right_align_nth_8 tr td:nth-child(8), 
.table_right_align_nth_8 tr th:nth-child(8){
    text-align:right;
}
.table_right_align_nth_9 tr td:nth-child(9), 
.table_right_align_nth_9 tr th:nth-child(9){
    text-align:right;
}
.table_right_align_nth_10 tr td:nth-child(10), 
.table_right_align_nth_10 tr th:nth-child(10){
    text-align:right;
}

.table-striped tbody tr:nth-of-type(even) {
    background-color: #fafafa;
}

.table-striped tbody tr:nth-of-type(odd) {
    background-color: #fff;
	--bs-table-accent-bg:#fff;
}

.fix_col tbody th{
	position: -webkit-sticky;
    position: sticky;
	background:#fff;
	left:0;
	min-width: 200px;
    max-width: 300px;
}
.fix_col tbody tr:nth-of-type(even) th{
	background:#fafafa;
	border-bottom:1px solid #ededed;
}
.fix_col thead th:first-child{
	position: -webkit-sticky;
    position: sticky;
	left:0;
	min-width: 200px;
    max-width: 300px;
}
table.sty01 td{
    font-size:14px;
}

.inner_banner .about {
    min-height:150px;
    background-image: url(../images/banner_01.jpg);
    background-size: cover;
    display: flex;
    align-items: center;
}

.inner_banner .pg_hed {
    font-size: 40px !important;
    font-family: 'Graphik Medium';
    color: #fff;
}

.bredcrum {
    padding-top: 8px;
    padding-bottom: 8px;
    border-bottom: 1px solid #e5e5e5;
    font-size: 1.6rem;
}

.bredcrum a {
	font-family: 'Graphik Medium';
    color: #085196;
    font-size:1.6rem;
}
.bredcrum span{
     font-size:1.6rem;
}
/* About css */
.about-info ul.checkList-a li {
    margin-bottom: 14px;
   
}
.about-info figure {
    box-shadow: 1px 2px 7px rgb(0 0 0 / 20%);
}
.bredcrum span {
    font-family: 'Graphik Regular';
}
/* ORG Chart css */
.org_icon {
    background-image: url(../images/org_icon.png);
    background-repeat: no-repeat;
    display: inline-block;
    vertical-align: middle;
}

.org_icon.ceeo {
    width:68px;
    height:68px;
    background-position: 15px 7px;
	zoom:0.8;
}

.org_icon.direc{
    width:68px;
    height:68px;
    background-position: -86px -1px;
	zoom:0.8;
}

.org_icon.inclsion{
    width:68px;
    height:68px;
    background-position: -171px -1px;
	zoom:0.8;
}


.orgstrucure .sec_ind{
	position:relative;
}

.orgstrucure .sec_ind.toplevl:after{
	position:absolute;
	content:"";
	width:1px;
	height:30px;
	z-index:-1;
	border-left:2px dashed #007a35;
	left:50%;
	top:100%;
}

.orgstrucure .sec_ind .fa-light, .org_icon.ceeo{
	font-size:36px;
	line-height:2;
	width:90px;
	height:90px;
	margin:auto;
	background-color:#007a35;
	color:#fff;
	border:5px solid #fff;
	border-radius:50%;
	text-align:center;
	position:relative;
    display: flex;
    align-items: center;
    justify-content: center;
}

.orgstrucure .sec_ind{
	margin-bottom:30px;
}
.orgstrucure .sec_grps .sec_ind {
    margin: auto;
    margin-bottom: 30px;
    max-width: 209px;
    width: 100%;
    text-align: center;
}

.orgstrucure .sec_ind .fa-light:after, .org_icon.ceeo:after{
    content:'';
	position:absolute;
	top:-6px;
	left:-6px;
	width:92px;
	height:92px;
	border-radius:50%;
	border:1px solid #007a35;
	 color:#fff;
}

.orgstrucure .sec_ind .caption{
    font-size: 1.8rem;
    background: #f6f8f8;
    border-radius: 50px;
    padding: 27px;
    display: inline-block;
    margin-top: -15px;
}
.orgstrucure .sec_grps .sec_ind .caption {
    padding:15px 5px;
    display: inline-block;
    margin-top: -10px;
    max-width: 209px;
    width: 100%;
}

.orgstrucure .sec_ind.toplevl b{
	font-size:1.9rem;
	min-width:250px;
}
/*gallery_governmentNotification*/
.gallery_governmentNotification .notification-col, .gallery_governmentNotification .gallery-col{
    padding-top:40px;
    padding-bottom:40px;
}
.gallery_governmentNotification .notification-col #myTab{
    border-bottom: 1px solid #3276bb !important;
    padding-bottom: 16px;
    margin-bottom: 35px !important;
}
.gallery_governmentNotification .notification-col #myTab button.nav-link {
    font-size: 2rem;
    padding:0 !important;
    margin-right: 10px;
    padding-right:10px !important;
}
.gallery_governmentNotification .notification-col .item{
    border-bottom: 1px solid #26659f;
    transition:.3s;
    padding-bottom: 15px;
    margin-bottom: 15px !important;
}
.gallery_governmentNotification .notification-col .item:last-child{
    border-bottom:0;    
}
.gallery_governmentNotification .notification-col .item:hover{
        border-color: #fbd10a;
}

/*inner_pg*/
.inner_pg .right-info-col:hover{
    
    background: #fbfbfb;

}

/*letest-news-section*/
.letest-news-section{
        background: #085196;
}

.letest-news-section a.viewALLBTN {
        padding: 3px 24px;
    font-size: 14px;
    color: #000000;
    border-radius: 100vmax;
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    z-index: 1;
    background: #fbd10a;
    margin: auto;
    height: fit-content;
    padding-top: 7px;
}

 .marquee-head {
    margin-right: 9px;
    float: left;
    line-height: 19px;
    padding: 9.5px;
    padding-left: 0;
    color: #fbd10a;
    font-weight: 400;
    position: relative;
    padding-right: 8px;
    font-size: 1.8rem;
    border-right: 1px solid rgb(233 233 233 / 70%);
}
 .marquee-wrapper ,.header-top-marquee{
  overflow: hidden;
}
 .marquee-wrapper .marquee {
  /*width: 9999px;*/
  font-size: 1.2rem;
  overflow: hidden;
  padding: 5px 0px;
  color:#fff;
}

.marquee-wrapper .marquee div {
  padding: 5px 12px 0px 15px;
  float: left;
   color:#fff;
}

.marquee a {
  float: left;
  font-size: 1.5rem;
  font-weight: 400;
  text-decoration: none;
   color:#fff;
}
.marquee a:hover {
  color: yellow;
}

@media (min-width: 768px) and (max-width: 1199px ){
.orgstrucure .sec_grps .sec_ind .caption {
    max-width: 173px;
}
.orgstrucure .sec_grps:before {
    height: 35px;
}
.orgstrucure .sec_ind{
	margin-bottom:-5px;
}
}
@media (min-width:768px){
.main-footer ul li {
    width: 48%;
    display: inline-flex;
}
	.orgstrucure .sec_ind{
        transform: scale(.7);
    }
	.orgstrucure .sec_grps{
		position:relative;
		padding-bottom:525px;
		max-width:750px;
		margin-left:auto;
		margin-right:auto;
		
	}
	
	.orgstrucure .sec_grps:before{
        content: "";
        position: absolute;
        height: 60px;
        left: 73px;
        right: 90px;
        top: 0;
        border-top: 2px dashed #007a35;
        border-left: 2px dashed #007a35;
        border-right: 2px dashed #007a35;
        border-radius: 30px 30px 0px 0px
	}
	
	.orgstrucure .sec_grps .sec_ind:after {
		position: absolute;
		content: "";
		z-index: -1;
		border-left: 2px dashed #007a35;
		border-radius: 20px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8:after,
	.orgstrucure .sec_grps .sec_ind.i6:after,
	.orgstrucure .sec_grps .sec_ind.i4:after,
	.orgstrucure .sec_grps .sec_ind.i2:after {
		width: 1px;
		height:200px;
		left: 50%;
		bottom: 100%;
	}
	
	.orgstrucure .sec_grps .sec_ind.i7:after,
	.orgstrucure .sec_grps .sec_ind.i5:after,
	.orgstrucure .sec_grps .sec_ind.i3:after {
		width: 1px;
		height:30px;
		left: 50%;
		bottom: 100%;
	}
	
	.orgstrucure .sec_grps .sec_ind{
		position:absolute;
	}
	.orgstrucure .sec_grps .sec_ind.i1{
		left:-32px;
		top:-7px;
	}
	.orgstrucure .sec_grps .sec_ind.i2{
		left:114px;
		top:150px;
	}
	.orgstrucure .sec_grps .sec_ind.i3{
		left:117px;
		top:-7px;
        z-index: 2;
	}
	.orgstrucure .sec_grps .sec_ind.i4{
		left:263px;
		top:150px;
	}
	.orgstrucure .sec_grps .sec_ind.i5{
		left:264px;
		top:-7px;
        z-index: 2;
	}
	.orgstrucure .sec_grps .sec_ind.i6{
		left:395px;
		top:150px;
	}
	.orgstrucure .sec_grps .sec_ind.i7{
		left:404px;
		top:-7px;
	}
	.orgstrucure .sec_grps .sec_ind.i8{
		left:550px;
		top:203px;
	}
	.orgstrucure .sec_grps .sec_ind.i9{
		left:545px;
		top:-7px;
	}
}

@media (min-width:1200px){
	
	.orgstrucure .sec_ind {
        transform: scale(1);
    }
	
	.orgstrucure .sec_grps {
		max-width: 1140px;
	}
	
	.org_icon.ceeo,
	.org_icon.direc,
	.org_icon.inclsion {
		zoom: normal;
	}
	
	.orgstrucure .sec_ind .fa-light, .org_icon.ceeo{
		font-size:48px;
		line-height: 2;
		width: 112px;
		height: 112px;
		border:6px solid #fff;
		color:#fff;
	}
	
	.orgstrucure .sec_ind .fa-light:after, .org_icon.ceeo:after{
		top: -8px;
		left: -8px;
		width: 116px;
		height: 116px;
		color:#fff;
	}
	
	.orgstrucure .sec_grps:before {
		left: 80px;
		right:80px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8:after, .orgstrucure .sec_grps .sec_ind.i6:after, .orgstrucure .sec_grps .sec_ind.i4:after, .orgstrucure .sec_grps .sec_ind.i2:after {
		height: 170px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i1 {
		left: -29px;
		top: 30px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i2 {
		left: 221px;
    top: 281px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i3 {
		left: 222px;
		top: 30px;
	}
	
	
	.orgstrucure .sec_grps .sec_ind.i4 {
		left: 466px;
        top: 281px;
	}
	
	
	.orgstrucure .sec_grps .sec_ind.i5 {
		left: 466px;
		top: 30px;
	}
	
	
	
	.orgstrucure .sec_grps .sec_ind.i6 {
		left: 588px;
		top: 172px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i7 {
		left: 715px;
		top: 30px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8 {
		left: 880px;
		top: 172px;
	}

	.orgstrucure .sec_grps .sec_ind.i9 {
		left: 962px;
		top: 30px;
	}
	
	
}

@media (min-width:1600px){
	
	.orgstrucure .sec_grps .sec_ind.i8:after, .orgstrucure .sec_grps .sec_ind.i6:after, .orgstrucure .sec_grps .sec_ind.i4:after, .orgstrucure .sec_grps .sec_ind.i2:after {
		height: 200px;
	}
	
	.orgstrucure .sec_ind {
		margin-bottom: 40px;
	}
	
	.orgstrucure .sec_ind.toplevl:after {
		height: 39px;
	}
	
	.orgstrucure .sec_ind b {
		font-size: 1.6rem;
		border-radius: 30px;
		padding: 5px 2px 5px;
		display: inline-block;
		margin-top: -6px;
	}
	
	.orgstrucure .sec_grps .sec_ind b {
		max-width: 180px;
	}
	
	.orgstrucure .sec_grps {
		max-width: 1400px;
		padding-bottom: 418px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i1 {
		left: -32px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i2 {
		left: 119px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i3 {
		left: 263px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i4 {
		left: 425px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i5 {
		left:596px;
		top: 30px;
	}

	.orgstrucure .sec_grps .sec_ind.i6 {
		left: 768px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i7 {
		left: 907px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8 {
		left: 1100px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i9 {
		left: 1219px;
	}
	
}

/* ORG Chart css */
@media(min-width:768px){
	
	.inner_banner .about {
		min-height:165px;
	}

	.inner_banner .pg_hed {
		font-size: 60px;
	}

	
}


/* ssb - 24-08-22 */

.what-new {
        margin: auto;
    position: absolute;
    top: 0;
    z-index: 2;
    background-color: rgba(255,255,255,.9);
    right: 0;
    padding: 30px;
    bottom: 0;
    max-width: 400px;
    max-height: 460px;
    height: fit-content;
    border-radius: 5px;
    overflow: hidden;
    width: 100%;
}

.right-info-col a h3{
    line-height:inherit;
}
.ashok-img img{
    width:80%;
    min-width:60px;
    max-height:100px;
}

.what-new .notify-items a:hover{
    color: #085196 !important;
}

.what-new .notify-items .item{
    
}

.notification-inner-col {
    margin-left:auto;
    margin-right: 0;
    width: 100%;
    margin-top: 0;
    display: flex;
    flex-direction: column;
    height: 100%;
}

.svg-map{
    max-width: 750px;
}

.common-svg{
    position: relative;
    cursor: pointer;
}

.common-svg-text{
    position: fixed;
  
    background: #085196;
    display: block;   
    color: #fff;    
    opacity: 0;    
    cursor: pointer;
    border-radius: 5px;
    left:10px;
}

.sty01 thead tr th{
    background:#085196;
}

.sty01 tr th,
.sty01 tr td{
    border:1px solid #eee;
}

.sty01 .text-right{
    text-align:right;
    
}

.sty01 b{
    font-family: 'Graphik Medium';
    font-weight:normal;
}

.common-section + .partner-sec{
    margin-top:30px;
}

.clor1{
    color:darkgreen;
    font-weight:700;

}

.sty01 + #lupdateddate{
    padding-right:1px;
}

.btn_ppac01 [class*=download]{
    margin-right:3px;
}

th strong,
td strong{
    font-weight:normal;
}

.list-group.list-group-horizontal{
    justify-content:center;
    margin-bottom:30px;
    display:none;
}

.formSearch li{
    font-size:1.7rem;
    margin-bottom:15px;
}

.searchContent h3 a{
    font-size:1.7rem;
}

.leftsearch h3{
    background:#085196;d
    padding:9px 15px;
    color:#fff;
}
.leftsearch form{
    padding:15px;
    padding-top:0;
}

.feedback-form .d-flex p{
    padding-left:10px;
}

.feedback-pg [class*=fa]{
    font-size:40px;
    color:#ffea00;
}

@media(min-width:768px){
    
    .in1line{
        display:block !important;
        width:100%;
        white-space:nowrap;
        overflow:hidden;
        text-overflow:ellipsis;
    }
    
    .in2line{
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
    }
    
    html{
        height:100%;
    }
    
    html body{
        display: flex;
        flex-direction: column;
    }
    .container.archiv,
    .contact-info.inner_pg ,
    body > .common-section{
        flex:1;
    }
    
}

@media(min-width:1200px){
    
    
    .notification-inner-col {
        max-width:600px;
    }
    
     body .logo .akam{
        max-width:105px;
    }
    
    .what-new-panel{
        width:1200px;
        top:0;
        left:0;
        right:0;
        bottom:0;
        position:absolute;
        margin:auto;
    }
    
    .screen-reader-nav{
        transform:translatex(36px);
    }
    
    .main-footer .mt-3 {
        margin-top: 3rem!important;
    }
    
}


@media(min-width:1440px){
    
    .notification-inner-col {
        max-width: 677px;
    }
    
    .banner-content {
        padding-left: 70px;
    }
    
    .home-banner-wrapper .container{
        max-width:calc(1440px - 50px);
    }
    
    body .logo .akam{
        max-width:145px;
    }
    
    .what-new-panel{
        width:1220px;
    }
    

    
}

@media(min-width:1600px){
    
    .banner-content {
        padding-left:0px;
    }
    .what-new-panel{
        width:1400px;
    }
}


@media(max-width:576px){
    
.notification-col {
    padding: 20px 15px !important;
}
  
}










#lupdateddate{
   color:darkgreen;
}
html{
    font-size: 57.5%;
    scroll-behavior: smooth;
    scroll-padding-top: 75px;
}
body{    
    font-family: 'Graphik Regular';
    margin: auto;
    width: 100%;
    height: 100%;     
    max-width: 1920px;
    color: #111111;
    overflow-x: hidden;
    padding-right: 0px !important;
}
.sticky {
  position: fixed;
  width: 100%;
  left: 0;
  top: 0;
  z-index: 100;
  border-top: 0;
}

.price-list li{
    position: relative;
    margin: 16px;
        width: 33.33%;
}
.price-list a {
    display: flex;
    color: #111;
    align-items: center;
    background: white;
    padding:20px;
    padding-left: 94px;
    box-shadow: 1px 2px 10px rgb(0 0 0 / 20%);
    border-radius: 5px;
        height: 100%;
}
.price-list a:hover{
    color:#085196;
}
ul.price-list.xls-icon li {
    margin-left: 0;
}
.price-list.xls-icon li:before{
    content:'\f1c3';
}
.price-list.xls-icon li.pdf:before{
    content:'\f1c1';
}
.price-list li:before{
    content: '\f08e';
    position: absolute;
    margin: auto;
    left: 5px;
    font-family: "Font Awesome 6 Pro";
    font-weight: 400;
    top: 0;
    bottom: 0;
    font-size: 48px;
    color: #085196;
    height: 53px;
}
.bredcrum span {
    //text-transform: lowercase;
    font-weight:500 !important;
}
.bredcrum::first-line{
  text-transform: capitalize !important;
}
/*Go to top*/
.go-top {
       position: fixed;
    bottom: 1%;
    right: 1%;
    display: none;
    cursor: pointer;
    -webkit-font-smoothing: antialiased;
    background-color: #085196;
    color: #fff;
    border-radius: 3px;
    font-size: 24px;
    padding: 7px 20px;
    padding-bottom: 1px;
}

/*Go to top*/
.iprr .checkList-a li a:hover {
    color: #085196;
     
}
.about ul li a:hover {
    text-decoration: underline;
}
.refeniry::-webkit-scrollbar {
  width: .5em;
   height: .5em;
  }
.refeniry::-webkit-scrollbar-track {
  background-color: #ececec;
}
::placeholder { /* Chrome, Firefox, Opera, Safari 10.1+ */
    font-size:1.6rem;
    color: #111111;
    font-family: var(fw400);
  }
  
  :-ms-input-placeholder { /* Internet Explorer 10-11 */
    font-size:1.6rem;
     color: #111111;
     font-family: var(--fw400);
  }
  
  ::-ms-input-placeholder { /* Microsoft Edge */
    font-size:1.6rem;
     color: #111111;
     font-family: var(fw400);
  }
  .text-dark {
    color: #111111!important;
}
.refeniry::-webkit-scrollbar-thumb {
  background-color: #085196;
}
.gallery-col{
    background-color:#007a35;
    padding: 25px 15px;
}
.gallery-inner-col {
    max-width: 655px;
}

.notification-inner-col .tab-content {
    display: flex;
    height: 100%;
}

.partner-sec ul li{
    /* max-width: 188px; */
    margin: 15px 0px;
    border: 1px solid #eee;
    padding: 0px;
}

body .partner-sec .item img{
    display:inline;
    width:auto;
}

.partner-sec .container{
    max-width:1300px;
}

.owl-carousel .owl-item{
    text-align:center;
}

.notification-col {
    background-image: url(../images/notifaction-bg.jpg);
    background-repeat: no-repeat;
    padding: 25px 30px;
    color: #fff;
    background-size: cover;
}
.notification-col .nav-link, .gallery-inner-col .nav-link{
    display: block;
    padding: 0rem 1rem !important;
    color: #ffffff !important;
    text-decoration: none;
    transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out;
    font-size: 1.8rem;
    font-family: var(--fw600) !important;
    border-right: 1px solid #fff;
    line-height: 23px;
}
.feedback-col {
    right: -66px;
    z-index: 2;
    top: 54%;
    transform: rotate(90deg);
}
.feedback-col .common-btn{
    background-color: #f07906 !important;
    color: #fff !important;
}
.notification-col .nav-tabs .nav-item.show .nav-link, .notification-col .nav-tabs .nav-link.active{
    color: #fbd10a !important;
    border-color: transparent;
    background-color: transparent;
    border-right: 1px solid #fff;
}
.gallery-inner-col .nav-tabs .nav-link.active{
    color: #fbd10a !important;
    border-color: transparent;
    background-color: transparent;
}
.notification-col .nav-tabs .nav-item .nav-link:hover{
    border-top: 1px solid transparent !important;
    border-bottom: 1px solid transparent !important;
    border-left: 1px solid transparent !important;
}
.gallery-inner-col .nav-tabs .nav-item .nav-link{
    border-top: 1px solid transparent !important;
    border-bottom: 1px solid transparent !important;
    border-left: 1px solid transparent !important;
        border-right: 1px solid #fff;
}
.modal-backdrop.show {
    width: 100%;
    height: 100%;
}
/*onload css*/
.onload-slider .modal-dialog {
    max-width: 1280px;
    width:100%;
    padding: 0px 30px;
}
.onload-slider .modal-body {
    padding: 0;
}
.onload-slider .btn-close, .feedback-slider  .btn-close{
    position: absolute;
    right: -31px;
    z-index: 10;
    background-color: #f8d116;
    opacity: 1;
    height: 43px;
    width: 43px;
    border-radius: 50%;
    font-weight: 500;
    top: -17px;
    padding: 0;
}
.feedback-slider h3{
    background-color: #f3f3f3;
    padding: 15px 30px;
    border-radius: 5px 0px 5px 0px;
}
.feedback-slider .modal-content{
   border-radius: 5px;   
}
.onload-slider .owl-carousel .owl-nav button.owl-next, .onload-slider .owl-carousel .owl-nav button.owl-prev{
    background-color: rgba(0,0,0,.8);
    padding: 10px 20px !important;
    border-radius: 5px 0px 0px 5px;
}
.onload-slider .owl-nav span {
    color: #f8d116;
}
.onload-slider .owl-carousel .owl-nav button.owl-prev{
    border-radius: 0px 5px 5px 0px;
}
/*TH stkey css*/
table.refeniry {
  position: absolute;
  border-collapse: transparent;
}

.refeniry thead {
       position: -webkit-sticky;
    position: sticky;
    top: -1px;
    border-right: 1px solid black !important;
    border-top: 1px solid #000 !important;
    /* border: 0px !important; */
    border: 1px solid #ededed !important;
    /* text-align: center !important; */
    box-shadow: 0px 2px 0 0 #eee;
    background: #eee;
}
.table-hover>tbody>tr:hover {
    --bs-table-accent-bg: var(--bs-table-hover-bg) !important;
    
}
.refeniry thead th:first-child {
  left: 0;
  z-index: 1;
}
.fix_col tbody th {
    /*border: 0px !important;*/
    border-bottom: 1px solid #ededed !important;
}
.refeniry td {
    /*border: 0px !important;*/
    border-bottom: 1px solid #ededed !important;
    /*text-align: right;*/
        font-size: 14px;

}
/*TH stkey css*/
.home-banner-wrapper{
    overflow:hidden;
}
.child-menu ul li a {
    font-size: 1.5rem;
    padding: 10px 12px;
}
.gallery-tab li.nav-item button.active, .gallery-tab li.nav-item button:hover {
    font-weight: 600;
    border: 0;
    color: #085196;
    border-bottom: 3px solid #085196;
}
.gallery-tab li.nav-item button {
    font-size: 1.8rem;
    font-weight: 600;
    color: #6e6e6e;
    border: 0;
    border-bottom: 3px solid transparent;
    padding: 5px 25px;
}
/*pagination*/
.pagination {
    justify-content: center;
}
.pagination .page-link{
    position: relative;
    display: block;
    color: #033667;
    border: 0;
    font-size: 18px;
    border-radius: 2px;
        margin: 0px 3px;
        padding: 1px 12px;
}
.pagination .page-link span{
    font-size: 18px;
}
.pagination .page-link:hover, .pagination .page-item.active .page-link{
    background-color: #007a35;
    color: #fff;
}
/*pagination*/
#photo figure a, #video figure a {
    max-height: 220px;
    overflow: hidden;
    display: block;
}
/*Loder css*/
.loader-sec {
    position: fixed;
    height: 100%;
    width: 100%;
    top: 0;
    background-color:#000000e0;
    z-index: 100;
    display: none;
    align-items: center;
}
.loader,
.loader:before,
.loader:after {
  background:#007a35;
  -webkit-animation: load1 1s infinite ease-in-out;
  animation: load1 1s infinite ease-in-out;
  width: 1em;
  height: 4em;
}
.loader {
  color: #007a35;
  text-indent: -9999em;
  position: relative;
  font-size: 11px;
  -webkit-transform: translateZ(0);
  -ms-transform: translateZ(0);
  transform: translateZ(0);
  -webkit-animation-delay: -0.16s;
  animation-delay: -0.16s;
  position: absolute;
    margin: auto;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
}
.loader:before,
.loader:after {
  position: absolute;
  top: 0;
  content: '';
}
.loader:before {
  left: -1.5em;
  -webkit-animation-delay: -0.32s;
  animation-delay: -0.32s;
}
.loader:after {
  left: 1.5em;
}
@-webkit-keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}
@keyframes load1 {
  0%,
  80%,
  100% {
    box-shadow: 0 0;
    height: 4em;
  }
  40% {
    box-shadow: 0 -2em;
    height: 5em;
  }
}

/*Loder css*/
select{
    background-image: url(../images/select-angle.png);
    background-repeat: no-repeat;
    background-position: right 8px center;
}
a, .text-blue{
    color: #085196;
}
.border-blue{
   border-color: #085196 !important; 
    display:none;
}
.about ul li:last-child a {
    border-right: 0 !important;
}
.about ul li:first-child a {
    padding-left:0px !important;
}
.border-res{
    border:1px solid #085196;
    padding: 14px 30px !important;
}
.border-res:hover{
    background-color:#085196 !important;
    color:#fff !important;
}
figure.main-img-gal {
    height:155px;
    overflow: hidden;
}
select option{
    padding: 5px;
}
select.no-select-angle{
    background-image: none;
}
.text-light-grey{
    color: #535353 !important;
}
.text-blue{
    color: #085196 !important;
}
.text-yellow{
    color: #fbd10a !important;
}
.bg-yellow{
    background-color: #fbd10a !important;
}
.border-blue{
    border-color: #085196 !important;
     display:none;
}
.bg-blue{
    background-color: #085196 !important;
}

.bg-sky-blue{
    background-color:#e1ecf6;
}
.bg-sky-light-blue{
    background-color:#f7fafc;
}

.bg-light-sky-blue{
    background-color: #f2f6fa;
}
.text-green{
    color: #007a35;
    margin:10;
}

.common-btn.bg-green{
    background-color: #007a35;
    color: #fff;
}
.common-btn.bg-green:hover{
    background-color: #085196;
    color: #fff;
}


.badge-notification{
    color: #004085;
    background-color: #dfedfd;
    line-height: normal;
}
.badge-act{
    color: #155724;
    background-color: #e3f1ea;
}
.badge-grade-c{
    color: #856404;
    background-color: #f9f4e3;
}
.badge-grade-a{
    color: #0c5460;
    background-color: #e8f3f7;
}

.fw300{
    font-family:var(--fw300) !important;
}
.fw400{
    font-family:var(--fw400) !important;
}
.fw500{
    font-family:var(--fw500) !important;
}
.fw600{
    font-family:var(--fw600) !important;
}
.fw700{
    font-family:var(--fw700) !important;
}


p,input,button,select,textarea, span,a ,div, .form-control{
    font-size: 1.4rem
}


.fz12{
    font-size: 1.2rem !important;
}
.fz13{
    font-size: 1.3rem !important;
}
.fz14, .dropdown-toggle{
    font-size: 1.4rem !important;
}
.fz15{
    font-size: 1.5rem !important;
}
.fz16{
    font-size: 1.6rem !important;
}
.fz18{
    font-size: 1.8rem !important;
}
.fz20{
    font-size:2rem !important;
}
.fz22{
    font-size: 2.2rem !important;
}
.fz24{
    font-size: 2.4rem !important;
}
.fz26{
    font-size: 2.6rem !important;
}
.fz28{
    font-size: 2.8rem !important;
}
.fz30{
    font-size: 3rem !important;
}
.fz32{
    font-size: 3.2rem !important;
}
.fz34{
    font-size: 3.4rem !important;
}
.fz36{
    font-size: 3.6rem !important;
}
.fz38{
    font-size: 3.8rem !important;
}
.fz40{
    font-size: 4rem !important;
}
.outline-0
{
    outline: none;

}
.new-batch {
    background-color: #dd1717a6;
    font-size: 11px;
    color: #fff;
    line-height: 15px;
    padding: 1px 5px;
    border-radius: 5px;
}
.btn-group{
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 1.4rem;
}

.btn-group *{
    border-radius: 4px !important;
}

ul{ padding: 0px; margin: 0px; list-style-type:none;}

.btn{
    font-size: 1.4rem;
    white-space: nowrap;
     text-align:right;
}
.my-3 {
    margin-top: 1rem!important;
    margin-bottom: 1rem!important;
}
.mx-2 {
    margin-right: 0.5rem!important;
    margin-left: 0.5rem!important;
}
.float-start {
    float: center!important;
}
.btn {
    display: inline-block;
    font-weight: 400;
    line-height: 1.5;
    font color: #fff;
    text-align: center;
    text-decoration: none;
    vertical-align: middle;
    cursor: pointer;
    -webkit-user-select: none;
    -moz-user-select: none;
    user-select: none;
    background-color: transparent;
    border: 1px solid transparent;
    padding: 0.375rem 0.75rem;
    font-size: 1rem;
    border-radius: 0.25rem;
    transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out,box-shadow .15s ease-in-out;
}
a{
    text-decoration: none;
}

/*dropdown css*/
.nav-ppac ul li {
    position: relative;
}
.nav-ppac ul ul {
    border: 1px solid #eee;
    position: absolute;
    background-color: #f8f9fa;
    min-width: 200px;
    z-index: 30;
    -webkit-transition: .3s ease;
    -o-transition: .3s ease;
    transition: .3s ease;
    visibility: hidden;
    opacity: 0;
}
.nav-ppac ul > li:hover > ul {
    margin-top: 9px;
    visibility: visible;
    opacity: 1;
}
.nav-ppac ul ul ul {
    left: 100%;
    top: 0;
    margin-top: 0 !important;
}
.nav-ppac .sub-child-menu:after {
    content: "\f107";
    font-family: 'Font Awesome 5 Pro';
    color: #fff;
    position: absolute;
    color: #000;
    right: 15px;
    top: 8px;
    -webkit-transform: rotate(-90deg);
    -ms-transform: rotate(-90deg);
    transform: rotate(-90deg);
}
.nav-ppac .child-menu:after {
    content: "\f107";
    font-family: 'Font Awesome 5 Pro';
    color: #fff;
    font-weight: 800;
    position: absolute;
    right: 10px;
    top: 9px;
}
.nav-ppac .child-menu:hover:after {
    color: #000;
}
.nav-ppac ul ul li:hover > a {
    background-color: #fff;
    color: #f07906;
}
.nav-ppac ul > li > ul {
    margin-top: 20px;
}
.nav-ppac ul > li:hover > ul {
    margin-top: 0px;
    visibility: visible;
    opacity: 1;
}
/*dropdown css*/
/* top-strip */
.top-strip{
    background-color: #ededed;
}

.top-strip li{
    color: #111111;
    font-size: 1.4rem;
    font-family: var(--fw400);
}
.top-strip li:hover a{
    color: #085196;
}
.top-strip li a{
    font-size: inherit;
    color: inherit;
}
.top-strip li:after{
    content: '|';
    margin: 0 6px;
}
.top-strip li:last-child::after {
    content: none   ;
}

#change_language{
    padding-right:2.7rem !important;
    transform: translateX(6px);
}

/* header-search */
.header-search{
    width: 100%;
    max-width: 350px;
}
.header-search i{
    position: absolute;
    left: 20px;
    font-size: 2rem;
    color: #085196;
    top: 0;
    bottom: 0;
    pointer-events: none;
    margin: auto;
    height: 21px;
}
.header-search .form-control{
    height: 42px;
    padding-left: 50px;
    color: #6e6e6e;
    font-size: 1.8rem;
}

/* header-navigation */
.header-navigation li a{
    font-size: 1.6rem;
    font-family: var(--fw400);
    color: #fff;
    padding:8px 28px;
    display: block;
}

.header-navigation .child-menu a{
    padding:8px 32px 8px 16px;
}

.header-navigation .nav-ppac > ul > li > a{
    text-transform: uppercase;
}


.logo img.img-fluid {
    max-width:80%;
}
.ashok-img img.img-fluid {
    max-width:80%;
}
.header-navigation li:hover a, .header-navigation li.active a{
    background-color: #f2f6fa;
    color: #000;
}
.contact-frm input.form-control, .feedback-slider input.form-control{
    height: 46px;
    border-radius: 5px;
    border-color: #b6b6b6;
    margin-bottom: 20px;
    box-shadow: none;
    padding-left: 15px;
}

.contact-frm textarea, .feedback-slider textarea{
    border-radius: 5px;
    border-color: #b6b6b6;
    padding-left: 15px;
}
/* owl-nav */
.owl-nav{
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    width: 100%;
    pointer-events: none;
    display: flex;
    justify-content: space-between;    
}
.owl-nav span{
    font-size: 0;
    width: 50px;
    height: 50px;    
    pointer-events: all;
}
.owl-nav .owl-prev span:after{
    content: "\f060";

}
.owl-nav .owl-next span:after{
    content: "\f061";
}

.owl-nav span:after{
    font-family:"Font Awesome 6 Pro";
    font-size: 2.8rem;
    font-weight: 600;
}

.offset-arrow-slider .owl-nav .owl-prev, .partner-slider .owl-nav .owl-prev{
    margin-left:-65px
}
.offset-arrow-slider .owl-nav .owl-next , .partner-slider .owl-nav .owl-next{
    margin-right:-65px
}
.offset-arrow-slider .owl-nav span:after , .partner-slider .owl-nav span:after{
    font-size: 22px;
    color: #fad00b;
}
.offset-arrow-slider .owl-nav span , .partner-slider .owl-nav span {
    border: 1px solid #fad00b;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
}
.offset-arrow-slider .owl-nav span:hover,  .partner-slider .owl-nav span:hover{
    border: 1px solid #fad00b;
    background:#fad00b;
}
.offset-arrow-slider .owl-nav span:hover:after, .partner-slider .owl-nav span:hover:after{
   color:#000;
}
/* banner-sliders */

.banner-sliders .item{
    position: relative;
}
.banner-content{
    position: absolute;
    width: 100%;
    top: 50%;
    transform: translateY(-50%);
}
.banner-content h3{
    font-size: 5.5rem;
    font-family: var(--fw700);
    max-width: 650px;
    color: #fff;
    margin-bottom: 40px;
}

.banner-content a{
    border: 2px solid;
    font-size: 1.8rem;
    font-family: var(--fw600);
    color: #fff;
    background-color: #007a35;
    width: 180px;
    padding: 9px 0;
    border-radius: 7px;
    letter-spacing: .4px;    
    border-color: #fff;
}

.banner-content a:hover{
    background-color:#085196;
    color: #fff;
    border-color: #085196;
}

.banner-sliders .owl-nav{
    padding: 0 70px;
}
.banner-sliders .owl-nav span{
    color: #fff;
    border: 1px solid;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
}
.banner-sliders .owl-nav span:hover{
    background-color: #085196;
    border-color: #085196;
}

/* common-btn */
.common-btn{
    background-color: #085196;
    color: #fff;
    font-size: 1.8rem;
    padding: 15px 30px;
    display: inline-block;
    border-radius: 5px;
    box-shadow: 0 .5rem 1rem rgba(0,0,0,.15);
    font-family: var(--fw600) !important;
    line-height: 1.1;
}
.common-btn:hover{
    color: #fff;
    background-color: #007a35;
}

/* common-section */
.common-section{
    padding:25px 0;
}
.common-section .title{
    font-size:3.5rem;
    font-family: var(--fw700);
}
.common-section .desc{
    font-size: 1.8rem;    
}
.snapshot-bg h2, .snapshot-bg h3, .snapshot-bg h4, .snapshot-bg p, .snapshot-bg .checkList-a li a{
    color: #fff;
   
}
.snapshot-bg .checkList-a li::before {
    color:#fff;
  
}
.snapshot-bg .common-btn {
    background-color: #fbd10a !important;
    color:#111111;
}
.snapshot-bg .common-btn:hover{
        box-shadow: 0 0.5rem 1rem rgb(0 0 0 / 35%);
}
.snapshot-bg figure{
    border-radius: 5px;
    overflow: hidden;
}
/* snapshot-bg */
.snapshot-bg{
    background: url(../images/arr-bg.jpg) no-repeat;
    background-size: cover;
}

/* checkList */
.snapshot-bg ul.checkList-a li {
    color: #fff;
     
}
.checkList-a li
 
.checkList-a li a , 
.checkList li{
    display: block;
    margin-bottom:5px;
    font-size: 1.8rem;
    display: flex;
    color: #000;
    
}
/*.checkList-a li a{*/
/*    text-decoration: underline;*/
/*}*/
.checkList-a li a:hover{
    color:#fbd10a;
      
}

// .checkList-a li::before{
//     content: '\f058';
//     font-family: "Font Awesome 6 Pro";
//     margin-right: 1px;
//     color:#000;
//     font: var(--fa-font-regular);
//     font-weight: 400;
//   
// }
.checkList-a li::before {
    content: '\f058';
    font-family: "Font Awesome 6 Pro";
    margin-right: 15px;
}

/* important-reports-slider */
.important-reports-slider .item{
    padding: 25px;
    display: flex;
    flex-direction: column;
    height:100%;
        transition: .3s;
        justify-content:center;
    margin: 5px;
    border: 1px solid #6d8ead;
        border-radius: 5px;

}
.important-reports-slider .item a{
        display: flex;
    flex-direction: column;
    height:100%;
}

.important-reports-slider .item h3{
        margin: auto !important;
        font-size: 18px !important;
}
.imp-report-sec .owl-carousel .owl-stage {
    display: flex;
}
.important-reports-slider .owl-item .item:hover{
     background-color: #007a35; 
    border-radius: 5px;
    border-color:#eee;
    transform: scale(1.02);
}

.important-reports-slider .owl-item{
    padding-bottom:10px;
}
.border-notify-right{
    border-right: 1px solid #b7cde1;
}
.media-gallery figure{
    margin-bottom: 0;
    border: 1px solid #fff;
    border-radius: 5px;
}
.main-img-gal figcaption{
        position: absolute;
    bottom: 10;
    width: 80%;
    background-color: rgb(0 0 0 / 76%);
    font-size: 16px;
    color: #fbd10a;
    align-items: center;
    padding: 5px 20px;
    left: 0;
    right:10;
    font-weight: 600;
}
.media-gallery .col-6 figure{
    position: relative;
        height:85px;
    overflow: hidden;
}
.copyrught p {
    color: #fff;
}
.copyrught p + p {
    margin-bottom: 0;
}
.partner-slider .owl-nav {
   
}
.copyrught p a {
    color: #fff;
}
.pan01 .data_b1 + .data_b1 .form-control.sty01 {
    display: inline-block;
    width: 180px;
}
.media-gallery .col-6 figure:after{
    content: '\f065';
    background-color: rgb(0 0 0 / 90%);
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;
    position: absolute;
    pointer-events: none;
    opacity: 0;
    visibility: hidden;
    font-family: "Font Awesome 6 Pro";
    font-weight: 400;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
}
.gallery-page .media-gallery .col-6 figure {
    position: relative;
    max-height: 327px;
    overflow: hidden;
    height: auto;
}
.media-gallery .col-6 figure:hover:after{
    opacity:1;
    visibility: visible;
}

/* main-footer */
.main-footer{
    background-color: #252525;
    border-bottom: 1px solid #99999952;
    
}
.middle-footer{
    background-color: #252525;
    padding: 20px 0;
}

.middle-footer a{
    font-size: 2.2rem;
    color: #fff;
}
.footer-social-media a{
    border: 1px solid #333333;
    width: 60px;
    height: 60px;
    border-radius: 0px !important;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color:#151515;
}
.footer-social-media a:hover{
    color: #007a35;
}
.main-footer h4{
    color: #fff;
    font-size: 2.2rem;
    font-family: var(--fw600) !important;
}
.main-footer a{
    color: #fff;
    font-size: 1.8rem;
    font-family: var(--fw400);
}
.main-footer a.common-btn {
    font-size: 1.8rem;
}
.main-footer a:hover{
    color: #aaa;
}
.main-footer  ul li{
    margin-bottom: 6px;
}
.copyrught{
    background-color: #151515;
    padding: 10px 0;
}


.grphbx{
	background:#fff;
	box-shadow:0 0 12px rgba(0,0,0,0.12);
	padding:40px;
	margin-right:40px;
	margin-top:20px;
	position:relative;
}

.grphbx:before{
	content:"";
	position:absolute;
	z-index:-1;
	right:-40px;
	top:-40px;
	background:#007a35;
	width:50%;
	max-width:600px;
	bottom:40px;
}

.btn_ppac01{
display: flex;
justify-content: center;
align-items: center;
	  font-size: 15px;
    color: #fff;
    background-color: #085196;
    border-color: #085196;
    padding: 8px 17px;
    visibility: visible;
	  text-align: right;
	 

}
.btn_ppac01:focus,
.btn_ppac01:hover{
		color:#fff;
  background-color: #085196;
        outline:none;
      
}


.pan01 .rigt_s{
	flex:1;
}

.pan01 .data_b1 + .data_b1{
	margin-left:30px;
}

.form-control.sty01{
	display:inline-block;
	width:120px;
	border:0;
	color:#085196;
	font-size:16px;
}

b.tx01{
	color:#085196;
}

table.sty01 a{
	color:#007a35;
}

table.sty01 thead th{
         text-transform: uppercase;
    background: #085196 !important;
    border-bottom: 1px solid #085196 !important;
    color: #fff;
    padding: 10px;
    font-weight: 500;
    text-align: center;
    font-size: 16px;
}
table.sty01 thead td {
    background-color: #fff !important;
     border-spacing: 0px;
}

.table>:not(caption)>*>*{
	padding:1rem;
	border-bottom:1px solid #ededed;
}

.table_right_align_nth_1 tr td:nth-child(1), 
.table_right_align_nth_1 tr th:nth-child(1){
    text-align:right;
}
.table_right_align_nth_2 tr td:nth-child(2), 
.table_right_align_nth_2 tr th:nth-child(2){
    text-align:right;
}
.table_right_align_nth_3 tr td:nth-child(3), 
.table_right_align_nth_3 tr th:nth-child(3){
    text-align:right;
}
.table_right_align_nth_4 tr td:nth-child(4), 
.table_right_align_nth_4 tr th:nth-child(4){
    text-align:right;
}
.table_right_align_nth_5 tr td:nth-child(5), 
.table_right_align_nth_5 tr th:nth-child(5){
    text-align:right;
}
.table_right_align_nth_6 tr td:nth-child(6), 
.table_right_align_nth_6 tr th:nth-child(6){
    text-align:right;
}
.table_right_align_nth_7 tr td:nth-child(7), 
.table_right_align_nth_7 tr th:nth-child(7){
    text-align:right;
}
.table_right_align_nth_8 tr td:nth-child(8), 
.table_right_align_nth_8 tr th:nth-child(8){
    text-align:right;
}
.table_right_align_nth_9 tr td:nth-child(9), 
.table_right_align_nth_9 tr th:nth-child(9){
    text-align:right;
}
.table_right_align_nth_10 tr td:nth-child(10), 
.table_right_align_nth_10 tr th:nth-child(10){
    text-align:right;
}

.table-striped tbody tr:nth-of-type(even) {
    background-color: #fafafa;
}

.table-striped tbody tr:nth-of-type(odd) {
    background-color: #fff;
	--bs-table-accent-bg:#fff;
}

.fix_col tbody th{
	position: -webkit-sticky;
    position: sticky;
	background:#fff;
	left:0;
	min-width: 200px;
    max-width: 300px;
}
.fix_col tbody tr:nth-of-type(even) th{
	background:#fafafa;
	border-bottom:1px solid #ededed;
}
.fix_col thead th:first-child{
	position: -webkit-sticky;
    position: sticky;
	left:0;
	min-width: 200px;
    max-width: 300px;
}
table.sty01 td{
    font-size:14px;
}

.inner_banner .about {
    min-height:150px;
    background-image: url(../images/banner_01.jpg);
    background-size: cover;
    display: flex;
    align-items: center;
}

.inner_banner .pg_hed {
    font-size: 40px !important;
    font-family: 'Graphik Medium';
    color: #fff;
}

.bredcrum {
    padding-top: 8px;
    padding-bottom: 8px;
    border-bottom: 1px solid #e5e5e5;
    font-size: 1.6rem;
}

.bredcrum a {
	font-family: 'Graphik Medium';
    color: #085196;
    font-size:1.6rem;
}
.bredcrum span{
     font-size:1.6rem;
}
/* About css */
.about-info ul.checkList-a li {
    margin-bottom: 14px;
   
}
.about-info figure {
    box-shadow: 1px 2px 7px rgb(0 0 0 / 20%);
}
.bredcrum span {
    font-family: 'Graphik Regular';
}
/* ORG Chart css */
.org_icon {
    background-image: url(../images/org_icon.png);
    background-repeat: no-repeat;
    display: inline-block;
    vertical-align: middle;
}

.org_icon.ceeo {
    width:68px;
    height:68px;
    background-position: -1px -1px;
	zoom:0.8;
}

.org_icon.direc{
    width:68px;
    height:68px;
    background-position: -86px -1px;
	zoom:0.8;
}

.org_icon.inclsion{
    width:68px;
    height:68px;
    background-position: -171px -1px;
	zoom:0.8;
}


.orgstrucure .sec_ind{
	position:relative;
}

.orgstrucure .sec_ind.toplevl:after{
	position:absolute;
	content:"";
	width:1px;
	height:30px;
	z-index:-1;
	border-left:2px dashed #007a35;
	left:50%;
	top:100%;
}

.orgstrucure .sec_ind span{
	font-size:36px;
	line-height:2;
	width:90px;
	height:90px;
	margin:auto;
	background-color:#007a35;
	color:#fff;
	border:5px solid #fff;
	border-radius:50%;
	text-align:center;
	position:relative;
    display: flex;
    align-items: center;
    justify-content: center;
}

.orgstrucure .sec_ind{
	margin-bottom:30px;
}
.orgstrucure .sec_grps .sec_ind {
    margin: auto;
    margin-bottom: 30px;
    max-width: 209px;
    width: 100%;
    text-align: center;
}

.orgstrucure .sec_ind span:before{
	content:"";
	position:absolute;
	top:-6px;
	left:-6px;
	width:92px;
	height:92px;
	border-radius:50%;
	border:1px solid #007a35;
}

.orgstrucure .sec_ind figcaption{
    font-size: 1.8rem;
    background: #f6f8f8;
    border-radius: 50px;
    padding: 27px;
    display: inline-block;
    margin-top: -15px;
}
.orgstrucure .sec_grps .sec_ind figcaption {
    padding:15px 5px;
    display: inline-block;
    margin-top: -10px;
    max-width: 209px;
    width: 100%;
}

.orgstrucure .sec_ind.toplevl b{
	font-size:1.9rem;
	min-width:250px;
}
/*gallery_governmentNotification*/
.gallery_governmentNotification .notification-col, .gallery_governmentNotification .gallery-col{
    padding-top:40px;
    padding-bottom:40px;
}
.gallery_governmentNotification .notification-col #myTab{
    border-bottom: 1px solid #3276bb !important;
    padding-bottom: 16px;
    margin-bottom: 35px !important;
}
.gallery_governmentNotification .notification-col #myTab button.nav-link {
    font-size: 2rem;
    padding:0 !important;
    margin-right: 10px;
    padding-right:10px !important;
}
.gallery_governmentNotification .notification-col .item{
    border-bottom: 1px solid #26659f;
    transition:.3s;
    padding-bottom: 15px;
    margin-bottom: 15px !important;
}
.gallery_governmentNotification .notification-col .item:last-child{
    border-bottom:0;    
}
.gallery_governmentNotification .notification-col .item:hover{
        border-color: #fbd10a;
}

/*inner_pg*/
.inner_pg .right-info-col:hover{
    
    background: #fbfbfb;

}

/*letest-news-section*/
.letest-news-section{
        background: #085196;
}

.letest-news-section a.viewALLBTN {
        padding: 3px 24px;
    font-size: 14px;
    color: #000000;
    border-radius: 100vmax;
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    z-index: 1;
    background: #fbd10a;
    margin: auto;
    height: fit-content;
    padding-top: 7px;
}

 .marquee-head {
    margin-right: 9px;
    float: left;
    line-height: 19px;
    padding: 9.5px;
    padding-left: 0;
    color: #fbd10a;
    font-weight: 400;
    position: relative;
    padding-right: 8px;
    font-size: 1.8rem;
    border-right: 1px solid rgb(233 233 233 / 70%);
}
 .marquee-wrapper ,.header-top-marquee{
  overflow: hidden;
}
 .marquee-wrapper .marquee {
  width: 9999px;
  font-size: 1.2rem;
  overflow: hidden;
  padding: 5px 0px;
  color:#fff;
}

.marquee-wrapper .marquee div {
  padding: 5px 12px 0px 15px;
  float: left;
   color:#fff;
}

.marquee a {
  float: left;
  font-size: 1.5rem;
  font-weight: 400;
  text-decoration: none;
   color:#fff;
}
.marquee a:hover {
  color: yellow;
}

@media (min-width: 768px) and (max-width: 1199px ){
.orgstrucure .sec_grps .sec_ind figcaption {
    max-width: 173px;
}
.orgstrucure .sec_grps:before {
    height: 35px;
}
.orgstrucure .sec_ind{
	margin-bottom:-5px;
}
}
@media (min-width:768px){
.main-footer ul li {
    width: 48%;
    display: inline-flex;
}
	.orgstrucure .sec_ind{
        transform: scale(.7);
    }
	.orgstrucure .sec_grps{
		position:relative;
		padding-bottom:525px;
		max-width:750px;
		margin-left:auto;
		margin-right:auto;
		
	}
	
	.orgstrucure .sec_grps:before{
        content: "";
        position: absolute;
        height: 60px;
        left: 73px;
        right: 90px;
        top: 0;
        border-top: 2px dashed #007a35;
        border-left: 2px dashed #007a35;
        border-right: 2px dashed #007a35;
        border-radius: 30px 30px 0px 0px
	}
	
	.orgstrucure .sec_grps .sec_ind:after {
		position: absolute;
		content: "";
		z-index: -1;
		border-left: 2px dashed #007a35;
		border-radius: 20px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8:after,
	.orgstrucure .sec_grps .sec_ind.i6:after,
	.orgstrucure .sec_grps .sec_ind.i4:after,
	.orgstrucure .sec_grps .sec_ind.i2:after {
		width: 1px;
		height:200px;
		left: 50%;
		bottom: 100%;
	}
	
	.orgstrucure .sec_grps .sec_ind.i7:after,
	.orgstrucure .sec_grps .sec_ind.i5:after,
	.orgstrucure .sec_grps .sec_ind.i3:after {
		width: 1px;
		height:30px;
		left: 50%;
		bottom: 100%;
	}
	
	.orgstrucure .sec_grps .sec_ind{
		position:absolute;
	}
	.orgstrucure .sec_grps .sec_ind.i1{
		left:-32px;
		top:-7px;
	}
	.orgstrucure .sec_grps .sec_ind.i2{
		left:114px;
		top:150px;
	}
	.orgstrucure .sec_grps .sec_ind.i3{
		left:117px;
		top:-7px;
        z-index: 2;
	}
	.orgstrucure .sec_grps .sec_ind.i4{
		left:263px;
		top:150px;
	}
	.orgstrucure .sec_grps .sec_ind.i5{
		left:264px;
		top:-7px;
        z-index: 2;
	}
	.orgstrucure .sec_grps .sec_ind.i6{
		left:395px;
		top:150px;
	}
	.orgstrucure .sec_grps .sec_ind.i7{
		left:404px;
		top:-7px;
	}
	.orgstrucure .sec_grps .sec_ind.i8{
		left:550px;
		top:203px;
	}
	.orgstrucure .sec_grps .sec_ind.i9{
		left:545px;
		top:-7px;
	}
}

@media (min-width:1200px){
	
	.orgstrucure .sec_ind {
        transform: scale(1);
    }
	
	.orgstrucure .sec_grps {
		max-width: 1140px;
	}
	
	.org_icon.ceeo,
	.org_icon.direc,
	.org_icon.inclsion {
		zoom: normal;
	}
	
	.orgstrucure .sec_ind span {
		font-size:48px;
		line-height: 2;
		width: 112px;
		height: 112px;
		border:6px solid #fff;
	}
	
	.orgstrucure .sec_ind span:before {
		top: -8px;
		left: -8px;
		width: 116px;
		height: 116px;
	}
	
	.orgstrucure .sec_grps:before {
		left: 80px;
		right:80px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8:after, .orgstrucure .sec_grps .sec_ind.i6:after, .orgstrucure .sec_grps .sec_ind.i4:after, .orgstrucure .sec_grps .sec_ind.i2:after {
		height: 170px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i1 {
		left: -29px;
		top: 30px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i2 {
		left: 221px;
    top: 281px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i3 {
		left: 222px;
		top: 30px;
	}
	
	
	.orgstrucure .sec_grps .sec_ind.i4 {
		left: 466px;
        top: 281px;
	}
	
	
	.orgstrucure .sec_grps .sec_ind.i5 {
		left: 466px;
		top: 30px;
	}
	
	
	
	.orgstrucure .sec_grps .sec_ind.i6 {
		left: 588px;
		top: 172px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i7 {
		left: 715px;
		top: 30px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8 {
		left: 880px;
		top: 172px;
	}

	.orgstrucure .sec_grps .sec_ind.i9 {
		left: 962px;
		top: 30px;
	}
	
	
}

@media (min-width:1600px){
	
	.orgstrucure .sec_grps .sec_ind.i8:after, .orgstrucure .sec_grps .sec_ind.i6:after, .orgstrucure .sec_grps .sec_ind.i4:after, .orgstrucure .sec_grps .sec_ind.i2:after {
		height: 200px;
	}
	
	.orgstrucure .sec_ind {
		margin-bottom: 40px;
	}
	
	.orgstrucure .sec_ind.toplevl:after {
		height: 39px;
	}
	
	.orgstrucure .sec_ind b {
		font-size: 1.6rem;
		border-radius: 30px;
		padding: 5px 2px 5px;
		display: inline-block;
		margin-top: -6px;
	}
	
	.orgstrucure .sec_grps .sec_ind b {
		max-width: 180px;
	}
	
	.orgstrucure .sec_grps {
		max-width: 1400px;
		padding-bottom: 418px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i1 {
		left: -32px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i2 {
		left: 119px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i3 {
		left: 263px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i4 {
		left: 425px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i5 {
		left:596px;
		top: 30px;
	}

	.orgstrucure .sec_grps .sec_ind.i6 {
		left: 768px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i7 {
		left: 907px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i8 {
		left: 1100px;
		top: 203px;
	}
	
	.orgstrucure .sec_grps .sec_ind.i9 {
		left: 1219px;
	}
	
}

/* ORG Chart css */
@media(min-width:768px){
	
	.inner_banner .about {
		min-height:165px;
	}

	.inner_banner .pg_hed {
		font-size: 60px;
	}

	
}


/* ssb - 24-08-22 */

.what-new {
        margin: auto;
    position: absolute;
    top: 0;
    z-index: 2;
    background-color: rgba(255,255,255,.9);
    right: 0;
    padding: 30px;
    bottom: 0;
    max-width: 400px;
    max-height: 460px;
    height: fit-content;
    border-radius: 5px;
    overflow: hidden;
    width: 100%;
}

.right-info-col a h3{
    line-height:inherit;
}
.ashok-img img{
    width:80%;
    min-width:60px;
    max-height:100px;
}

.what-new .notify-items a:hover{
    color: #085196 !important;
}

.what-new .notify-items .item{
    
}

.notification-inner-col {
    margin-left:auto;
    margin-right: 0;
    width: 100%;
    margin-top: 0;
    display: flex;
    flex-direction: column;
    height: 100%;
}

.svg-map{
    max-width: 750px;
}

.common-svg{
    position: relative;
    cursor: pointer;
}

.common-svg-text{
    position: fixed;
  
    background: #085196;
    display: block;   
    color: #fff;    
    opacity: 0;    
    cursor: pointer;
    border-radius: 5px;
}

.sty01 tr th{
    background:#085196;
}

.sty01 tr th,
.sty01 tr td{
    border:1px solid #eee;
}

.sty01 .text-right{
    text-align:right;
}

.sty01 b{
    font-family: 'Graphik Medium';
    font-weight:normal;
}

@media(min-width:768px){
    
    .in1line{
        display:block !important;
        width:100%;
        white-space:nowrap;
        overflow:hidden;
        text-overflow:ellipsis;
    }
    
    .in2line{
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
    }
    
}

@media(min-width:1200px){
    
    
    .notification-inner-col {
        max-width:600px;
    }
    
     body .logo .akam{
        max-width:105px;
    }
    
    .what-new-panel{
        width:1200px;
        top:0;
        left:0;
        right:0;
        bottom:0;
        position:absolute;
        margin:auto;
    }
    
    .screen-reader-nav{
        transform:translatex(36px);
    }
    
    .main-footer .mt-3 {
        margin-top: 3rem!important;
    }
    
}


@media(min-width:1440px){
    
    .notification-inner-col {
        max-width: 677px;
    }
    
    .banner-content {
        padding-left: 70px;
    }
    
    .home-banner-wrapper .container{
        max-width:calc(1440px - 50px);
    }
    
    body .logo .akam{
        max-width:145px;
    }
    
    .what-new-panel{
        width:1220px;
    }
    
    .screen-reader-nav{
        transform:translatex(72px);
    }
    
}

@media(min-width:1600px){
    
    .banner-content {
        padding-left:0px;
    }
    .what-new-panel{
        width:1400px;
    }
}


@media(max-width:576px){
    
.notification-col {
    padding: 20px 15px !important;
}
  
}
.col-sm-6{
margin-left:2px;
margin-right:11px;
margin-bottom:8px;
}
.p-5{
margin-right:11px;
}
.checkList-a
{  list-style-type: disc;
  list-style-position: outside;
}

.text-end {
  text-align: end;
 
}
.row align-items-center my-4{
  font color: #fff;
  color :#fff;
}


      </style>
      
        <body class="col-sm-6" class="row align-items-center my-4" class="checkList-a" class="text-end" style="background-color:#fff;height:100vh;"
      >
        

        $pagecontent   
        
        </body>
      </html>
      
    ''');
  }

  List details = [];
  bool isDone = false;
  bool isLoading = true;

  bool isDownloadStart = false;

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          details.add(message.message);
          print(details);
          setState(() {
            isDone = true;
          });
          if (isDone == true) {
            setState(() {
              isDone = false;
            });
          }
        });
  }

  _loadHTML() async {

    _con.loadUrl(Uri.dataFromString(setHTML(TABULARPAGECONTENT.pagecontent),
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  _loadHTMLtwo() async {
    TABULARPAGECONTENT.pagecontent = """<ul class='list-group'>
        
        <li class='list-group-item'>Current</li>
        <li class='list-group-item'>History</li>
        </ul>""";
    _con.loadUrl(Uri.dataFromString(setHTML(TABULARPAGECONTENT.pagecontent),
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  void initState() {
    print("webviewinit called");
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }


  late WebViewController _con;
  int _stackToView = 1;

  CancelToken cancelToken = CancelToken();




  UniqueKey _key = UniqueKey();
  final GlobalKey webViewKey = GlobalKey();
  Future<bool> _onBack() async {
    var value = await _con.canGoBack();

    if (value) {
      await _con.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBack(),
      child: Scaffold(
        // backgroundColor: Colors.white,
        body: Center(
          child:
          SafeArea(
            child: IndexedStack(
              key:_key ,
              alignment: AlignmentDirectional.topStart,
              children: [

                WebView(
                  key: webViewKey,
                  allowsInlineMediaPlayback: true,
                  initialMediaPlaybackPolicy:
                      AutoMediaPlaybackPolicy.always_allow,
                  debuggingEnabled: true,
                  initialUrl: Platform.isAndroid
                      ? Uri.encodeFull(
                          '${ApiConstant.baseurl}${widget.slugname}')
                      : '',
                  javascriptMode: JavascriptMode.unrestricted,
                  zoomEnabled: true,

                  onWebViewCreated: (WebViewController webViewController) {
                    _con = webViewController;
                    //203=Production
                    if (ApiData.subMenuID == "203") {
                      _loadHTMLtwo();
                    } else {
                      _loadHTML();
                    }
                  },
                  onProgress: (int progress) {

                    print("WebView is loading (progress : $progress%)");
                  },
                  javascriptChannels: <JavascriptChannel>{
                    _toasterJavascriptChannel(context),
                  },
                  onPageStarted: (url) {
                    setState(() {
                      isLoading = true;
                    });
                  },
                  onPageFinished: (status) {
                    setState(() {
                      isLoading = false;
                    });
                  },

                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer()),
                    Factory<HorizontalDragGestureRecognizer>(
                        () => HorizontalDragGestureRecognizer()),
                    Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer()),
                    Factory<ScaleGestureRecognizer>(
                        () => ScaleGestureRecognizer()),
                  },
                  navigationDelegate: (NavigationRequest request) async {
                    if (Platform.isAndroid) {
                      if (request.url.contains("mailto:")) {
                        canLaunchUrl(Uri(scheme: 'mailto', path: ''))
                            .then((bool result) {
                          launchUrl(
                            Uri(scheme: 'mailto', path: ''),
                            mode: LaunchMode.externalApplication,
                          );
                        });
                        return NavigationDecision.prevent;
                      } else if (request.url
                          .contains("https://ppac.gov.in/uploads/")) {

                        print('contain url webviewcontent');
                        _launchURL(request.url);

                        return NavigationDecision.prevent;
                      }
                    } else {
                      print('iOSblock in webview content:4454');


                      if (!request.url.contains('data:text/html;')) {
                        if (!request.url.contains(
                                '${ApiConstant.baseurl}infrastructure/installed-refinery-capacity') &&
                            (!request.url.contains('https://www.google.co')) &&
                            (!request.url.contains('about:blank'))) {
                          print('request.url: ${request.url}');

                          request.url.contains(ApiConstant.downloadEndpoint)
                              ? downloadios(dio, request.url)
                              : downloadios(dio,
                                  '${ApiConstant.downloadEndpoint}/${request.url}');

                          return NavigationDecision.prevent;
                        } else {
                          print('iOSblock in webview content:4424');
                          if (Platform.isIOS) {
                            _con.runJavascript(
                                "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
                            _con.runJavascript(
                                "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                            _con.runJavascript(
                                "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                            _con.runJavascript(
                                "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");
                            _con.loadUrl(
                                "javascript:var footer = document.querySelector('footer').style.display = 'none'; " +
                                    "var header = document.querySelector('header').style.display = 'none'; ");

                            _con.runJavascript(
                                "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                            _con.runJavascript(
                                "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                            _con.runJavascript(
                                "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");
                            _con.runJavascript(
                                "document.getElementsByClassName('nav nav-tabs mobc gallery-tab border-0')[0].remove()");
                            _con.runJavascript(
                                "document.getElementsByClassName('nav nav-tabs gallery-tab border-0')[0].remove()");

                            _con.runJavascript(
                                "document.getElementsByClassName('data_b1')[0].style.display='none';");
                            _con.runJavascript(
                                "document.getElementsByClassName('data_b1')[1].style.display='none';");

                            _con
                                .runJavascript(
                                    "document.getElementsByClassName(\"right_buttons\")[0].style.display='none';document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';document.getElementsByClassName(\"inner_banner\")[0].style.display='none';document.getElementsByClassName(\"bredcrum\")[0].style.display='none';document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';document.getElementsByClassName(\"header\")[0].style.display='none';document.querySelector('header').style.display = 'none';document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                                .then((value) => debugPrint(
                                    'Page finished loading Javascript'))
                                .catchError(
                                    (onError) => debugPrint('$onError'));
                            _con
                                .runJavascript(
                                    "document.getElementsByClassName(\"right_buttons\")[0].style.display='none';document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';document.getElementsByClassName(\"inner_banner\")[0].style.display='none';document.getElementsByClassName(\"bredcrum\")[0].style.display='none';document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';document.getElementsByClassName(\"header\")[0].style.display='none';document.querySelector('header').style.display = 'none';document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                                .then((value) => debugPrint(
                                    'Page finished loading Javascript'))
                                .catchError(
                                    (onError) => debugPrint('$onError'));
                          }
                        }
                      }

                    }

                    return NavigationDecision.navigate;
                  },

                  gestureNavigationEnabled: true,
                ),

                isLoading
                    ? Center(
                        child: Container(
                        width: 110,
                        height: 110,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Color(0xffF2F2F2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: CircularProgressIndicator(
                          color: Color(0xff085196),
                        ),
                      ))
                    : Stack(),


              ],
            ),
          ),
        ),


      ),
    );
  }

  Future downloadxlsfile(Dio dio, String url) async {
    try {
      File file = File(url);
      String fileName = file.path.split('/').last;
      print('file.path: ${fileName}');

      String fileext = fileName.split('.').last;

      var dir =
          await _getDownloadDirectory(); //await getApplicationDocumentsDirectory();
      print("path ${dir?.path ?? ""}");
      var filepath = "${dir?.path ?? ""}/$fileName";

      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);

      if (fileext == "xls") {
        File file1 = File("/storage/emulated/0/Download/Report.xls");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/vnd.ms-excel');
      } else if (fileext == "pdf") {
        File file1 = File("/storage/emulated/0/Download/Report.pdf");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/pdf');
      } else if (fileext == "xlsx") {
        File file1 = File("/storage/emulated/0/Download/Report.xlsx");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path,
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      }

    } catch (e) {
      print(e);
    }
    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
  }

  Future<void> downloadios(Dio dio, String url) async {
    print('Download url $url');
    File file = File(url);
    String fileName = file.path.split('/').last;

    String fileext = fileName.split('.').last;

    print('file.path: ${fileName}');
    var dir = await _getDownloadDirectory();
    print("path ${dir?.path ?? ""}");
    var filepath = "${dir?.path ?? ""}/$fileName";

    try {

      Response response =
      await dio.download(url, filepath, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          //  downloading = true;
          isdownload = true;
          _progress = "${((rec / total) * 100).toStringAsFixed(0)}%";
        });
      });

      if (fileext == "xls") {
        await OpenFile.open(filepath, type: "com.microsoft.excel.xls");
      } else if (fileext == "pdf") {
        await OpenFile.open(filepath, type: "com.adobe.pdf");
      } else if (fileext == "xlsx") {
        await OpenFile.open(filepath,
            type:
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      } else {
        await OpenFile.open(filepath, type: 'application/vnd.ms-excel');
      }

    } catch (e) {
      print(e);
    }

    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
    print("Download completed");
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print("0");
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
        print("_progress:$_progress");

        isdownload = true;
      });
      print((received / total * 100).toStringAsFixed(0) + "%");
    } else {
      print("1");
      setState(() {
        isdownload = false;
      });
    }
  }



  _launchURL(url) async {
    print('url: $url');
    if (await canLaunch(url)) {
      if (Platform.isAndroid) {
        await launch(url);
      } else if (Platform.isIOS) {
        print('_launchURL: in iOS Block');
        downloadios(dio, url.toString());
      }
    } else {
      throw 'Could not launch $url';
    }
  }




}
