#!/usr/bin/perl

use XBase;
use Cwd;
use File::Copy;
use Text::Iconv;
use Mail::Sender;
use Email::Send::SMTP::Gmail;
#use Email::Sender::Transport::SMTP::TLS;


@file_to_dir=();

# Начало
chdir ('/home/gaz/orel');
$local_dir=getcwd; #получение текущей директории
$backup_dir='/home/gaz/backup/orel';
#print "$local_dir\n";
#chdir ("$local_dir/files"); #изменение на рабочую директорию там где файлы zip
#$local_dir=getcwd; #получение текущей директории
#print "$local_dir\n";

@file_to_dir = glob "*.zip"; #получения списка файлов zip в папке
$size=@file_to_dir; #кол-во элементов в массиве (то есть  кол-во файлов )

#print "\n";
#print "@file_to_dir  \n\n";

$col_files=0; #количество файлов в папке


# проверка наличия файлов zip  если ничего нет выход

if (@file_to_dir!=()) {
$i=0;
$y=0;

#Если файлы есть начинаем сравнение каждого с последующими

until ($i>$size-1) {
$vhozdenie = substr $file_to_dir[$i], 2, 6;  #вырезка из имени файла его даты для поиска пары
#print "Значение $vhozdenie сравниваем с ";
$y=$i+1;


until ($y>$size-1) {
$vhozdenieee = substr $file_to_dir[$y], 2, 6;
#print "Значение второе $vhozdenieee для сравнения";
#push @pari, $vhozdenie;  #создание массива по шаблонам даты файла  для поиска пары
#print "Вхождение $vhozdenie    второе вхождение    $vhozdenieee\n";
#print "\n";
#print "\n";

if ($vhozdenie==$vhozdenieee) {
                               $sov++; #количество совпавших пар
#                               print "$i  совпадает с $y   \n\n";

#распаковываем найденную пару файлов
system ("unzip $file_to_dir[$i]");
system ("unzip $file_to_dir[$y]");

#-------------------------------------------------------------------------------------------------
chdir ("$local_dir/tmp"); #изменение на рабочую директорию там где файлы dbf
#$local_dir=getcwd; #получение текущей директории
@dly_zameni = glob "KM*.dbf";  #ищем транспортный файл
#print "файлы в директори     @dly_zameni \n";
#print "имя файла для замены и чтения  $dly_zameni[0]  \n";

#-------------------------------------------------------------------------------------------------


#извлекаем дату проводки из транспортного файла и присваиваем ему имя по дате проводки из него же
$dly_zamena=@dly_zameni[0];
my $table = new XBase "$dly_zamena" or die XBase->errstr;
         for (0 .. $table->last_record)
{
               my ($n_ree, $dt_bank, $plp, $sum_plp, $sum_psb, $sum_kw) = $table->get_record($_, "DT_BANK");
#               print "$dt_bank:\t$msg\n" unless $n_ree;
$data_provodki=$dt_bank; };
#print "Дата проводки платежа  $data_provodki   \n";
$new_data_provodki = substr $data_provodki, 2, 6;
#print "$new_data_provodki \n";
close my $table;
rename "$dly_zameni[0]", "KM$new_data_provodki.dbf";

#--------------------------------------------------------------------------------------------------
# ищем второй файл с реестром и отрезаем лишнюю _1 и т.д.
@dly_zameni = qw ();
@dly_zameni = glob "MK*.dbf"; # ищем файл с реестром
$dly_zamena=@dly_zameni[0];
$new_file_name = substr $dly_zamena, 0, 8;
rename "$dly_zameni[0]", "$new_file_name.dbf";
upakovka();
otpravka55();
move ("MK$vhozdenie.zip", "MK$vhozdenie$i.zip");
system ("cp -f MK$vhozdenie$i.zip $backup_dir/MK$vhozdenie$i.zip");
chdir ("$local_dir");
system ("rm -R $local_dir/tmp/*.*"); # очищаем директорию для следующей пары файлов
                    }; #закрывавет внутреннее условие если нашлась пара файлов
                            $y++; }; #закрывает цикл поиска второго файла для сравнения
                     $i++; };#закрывает цикл выбора первого файла для сравнения


#print "Всего файлов DBF в директории = $con_files\n";
#print "@pari\n";
#print "$sov   кол-во совпадений";
system ("rm -R $local_dir/tmp/"); #очищаем всё после обработки файлов
system ("mv $local_dir/*.zip $backup_dir/");  # mv /home/gaz/orel/*.zip /home/gaz/backup/;
}

else { print " нет файлов для отправки  \n" }





#----------------------------------- отправка сообщения----------------------------------------------
#----------------------------------------------------------------------------------------------------

sub otpravka55 {

$SERVER='smtp.gmail.com:587'; # адрес почтового сервера с портом
$FROM1='xxxxxx@mail.ru'; # почтовый ящик от имени которого письмо
$TO='xxxxxx@xxxxx.ru';# ящик на который откравляем

$TXT="Выгрузка реестров платежей  за $vhozdenie  ";
$filess="MK$vhozdenie.zip";  # переменная для передачи имени файла в сообщение

$converter = Text::Iconv -> new ("utf-8", "cp1251");
$newtxt= $converter -> convert ("$TXT");
$MSG=$newtxt;
$SUB=$newtxt;


my ($mail11, $error)=Email::Send::SMTP::Gmail->new ( -layer=>'ssl', -debug=> 1 ,-port=>'465', -smtp=>'smtp.gmail.com', -login=>'xxxxx@xxxxxx.ru', -pass=>'xxxxxxxxxx');
print "sesion error: $error" unless ($email!=1);
$mail11->send(-from=>'xxxxx@bxxxxxx.ru', -to=>'xxxx.xxxx@xxxxxxx.ru');
# -subject=>"$SUB", -attachments=>"$files");
mail11->bye;

};

#____________________________________________________________________________________________________
#упаковка всех dbf файлов в текущей директории
#sub upakovka { system ("zip MK$new_data_provodki *.dbf"); };
sub upakovka { system ("zip MK$vhozdenie *.dbf"); };
