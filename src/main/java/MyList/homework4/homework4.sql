SET search_path TO cinema;

drop table if exists films cascade;
create table films (
                       id 			bigserial primary key,
                       title 		varchar(255),
                       duration 	interval
);

insert into films (title, duration)
values
    ('Film 1', '60 minutes'),
    ('Film 2', '90 minutes'),
    ('Film 3', '120 minutes'),
    ('Film 4', '60 minutes'),
    ('Film 5', '90 minutes'),
    ('Film 6', '120 minutes');


drop table if exists sessions cascade;
create table sessions(
                         id 			bigserial primary key,
                         starttime	timestamp,
                         price		integer,
                         film_id		bigint not null,
                         foreign key (film_id) references films (id)
);

insert into sessions (starttime, price, film_id)
values
    ('2021-02-10 09:00:00', 200, 1),
    ('2021-02-10 11:00:00', 250, 2),
    ('2021-02-10 12:00:00', 250, 3),
    ('2021-02-10 10:00:00', 250, 4),
    ('2021-02-10 12:30:00', 300, 5),
    ('2021-02-10 10:40:00', 200, 6),
    ('2021-02-10 19:00:00', 400, 1),
    ('2021-02-10 20:30:00', 200, 2),
    ('2021-02-10 13:45:00', 300, 3),
    ('2021-02-10 15:10:00', 300, 4),
    ('2021-02-10 16:40:00', 300, 5),
    ('2021-02-10 20:50:00', 400, 6);

drop table if exists tickets cascade;
create table tickets(
                        id 			bigserial primary key,
                        session_id	bigint,
                        foreign key (session_id) references sessions (id)
);

insert into tickets (session_id)
values
    (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12),
    (2), (1), (3), (2), (5), (5), (5), (9), (9), (10), (10), (10),
    (9), (2), (3), (4), (5), (6), (4), (8), (9), (10), (1), (2),
    (11), (2), (5), (6), (5), (6), (7), (8), (9), (10), (11), (12),
    (12), (2), (5), (4), (5), (6), (7), (8), (10), (10), (11), (12),
    (7), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12);

--oshibki raspisaniya
--Сделать запросы, считающие и выводящие в понятном виде:
--ошибки в расписании (фильмы накладываются друг на друга), отсортированные по возрастанию времени.
--Выводить надо колонки «фильм 1», «время начала», «длительность», «фильм 2», «время начала», «длительность»;
with Tab1 as (
    select f1.title, s1.starttime, f1.duration, s1.id
    from films f1 join sessions s1 on f1.id = s1.film_id
),
     Tab2 as(
         select f2.title, s2.starttime, f2.duration, s2.id
         from films f2 join sessions s2 on f2.id = s2.film_id
     )
select t1.title, t1.starttime, t1.duration, t2.title, t2.starttime, t2.duration
from
    Tab1 t1, Tab2 t2
where (t1.starttime, t1.duration) overlaps  (t2.starttime, t2.duration)
  and t1.id <> t2.id
order by t1.starttime;

-- pereryvy
--перерывы 30 минут и более между фильмами — выводить по уменьшению длительности перерыва.
--Колонки «фильм 1», «время начала», «длительность», «время начала второго фильма», «длительность перерыва»;
with Tab1 as (
    select f1.title, s1.starttime, f1.duration, s1.id
    from films f1 join sessions s1 on f1.id = s1.film_id
),
     Tab2 as(
         select f2.title, s2.starttime, f2.duration, s2.id
         from films f2 join sessions s2 on f2.id = s2.film_id
     ),
     Tab3 as(
         select t1.starttime, MIN(t2.starttime - (t1.starttime + t1.duration))  as break
         from
             Tab1 t1, Tab2 t2
         where t2.starttime > (t1.starttime + t1.duration + interval '00:30:00')
         group by t1.starttime
     )
select distinct t1.title, t1.starttime, t1.duration, t2.starttime as nachalo_2, t3.break as break
from
    Tab1 t1, Tab2 t2, Tab3 t3
where (t2.starttime - (t1.starttime + t1.duration)) = t3.break
  and t1.starttime = t3.starttime
order by break desc
;

--film statistika
--список фильмов, для каждого — с указанием общего числа посетителей за все время,
--среднего числа зрителей за сеанс и общей суммы сборов по каждому фильму (отсортировать по убыванию прибыли).
--Внизу таблицы должна быть строчка «итого», содержащая данные по всем фильмам сразу;
(select f.title as film_title,
        count(t.session_id) as posetilo_vsego,
        round(avg(t.session_id)) as posetitelei_na_seans,
        sum(s.price) as sbory
 from films f
          join sessions s on s.film_id = f.id
          join tickets t on s.id = t.session_id
 group by film_title
 order by sbory desc)

union all

select 'itogo' as film_title,
       count(t.id) as posetilo_vsego,
       round(avg(t.session_id)) as posetitelei_na_seans,
       sum(s.price) as sbory
from films f
         join sessions s on s.film_id = f.id
         join tickets t on s.id = t.session_id;
--order by sbory desc;



-- statistika po vremennym promezhutkam
--число посетителей и кассовые сборы, сгруппированные по времени начала фильма: с 9 до 15, с 15 до 18, с 18 до 21, с 21 до 00:00
--(сколько посетителей пришло с 9 до 15 часов и т.д.).
select '9-15' as time, count(t.id), sum(s.price)
from sessions s
    join tickets t on s.id = t.session_id
where s.starttime >= '2021-02-10 09:00:00'
  and s.starttime < '2021-02-10 15:00:00'

union all

select '15-18' as time, count(t.id), sum(s.price)
from sessions s
    join tickets t on s.id = t.session_id
where s.starttime >= '2021-02-10 15:00:00'
  and s.starttime < '2021-02-10 18:00:00'

union all

select '18-21' as time, count(t.id), sum(s.price)
from sessions s
    join tickets t on s.id = t.session_id
where s.starttime >= '2021-02-10 18:00:00'
  and s.starttime < '2021-02-10 21:00:00'

union all

select '21-00' as time, count(t.id), sum(s.price)
from sessions s
    join tickets t on s.id = t.session_id
where s.starttime >= '2021-02-10 21:00:00'
  and s.starttime < '2021-02-11 00:00:00';
